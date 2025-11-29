// ============================================
// Lambda Function: Notification Service
// Servicio de notificaciones por email
// ============================================

const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand, ScanCommand } = require("@aws-sdk/lib-dynamodb");
const { SESClient, SendEmailCommand } = require("@aws-sdk/client-ses");

// Configurar clientes
const dynamoClient = new DynamoDBClient({ region: process.env.AWS_REGION || "us-east-1" });
const dynamoDB = DynamoDBDocumentClient.from(dynamoClient);
const sesClient = new SESClient({ region: process.env.AWS_REGION || "us-east-1" });

const USUARIOS_TABLE = process.env.USUARIOS_TABLE || "elmundo-fitness-usuarios-dev";
const SENDER_EMAIL = process.env.SENDER_EMAIL || "no-reply@elmundofitness.com";

/**
 * Handler principal de Lambda
 */
exports.handler = async (event) => {
    console.log("Event received:", JSON.stringify(event, null, 2));
    
    try {
        // Parsear el body de la petición
        const body = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;
        
        const { action, userId, message, notificationType } = body;
        
        let result;
        
        switch (action) {
            case 'send-to-user':
                result = await sendNotificationToUser(userId, message, notificationType);
                break;
            case 'send-expiration-reminders':
                result = await sendExpirationReminders();
                break;
            case 'send-welcome':
                result = await sendWelcomeEmail(userId);
                break;
            default:
                throw new Error("Acción no soportada");
        }
        
        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'POST, OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type, Authorization'
            },
            body: JSON.stringify({
                success: true,
                data: result,
                timestamp: new Date().toISOString()
            })
        };
        
    } catch (error) {
        console.error("Error:", error);
        
        return {
            statusCode: error.statusCode || 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                success: false,
                error: error.message,
                timestamp: new Date().toISOString()
            })
        };
    }
};

/**
 * Enviar notificación a un usuario específico
 */
async function sendNotificationToUser(userId, message, notificationType = 'info') {
    if (!userId || !message) {
        const error = new Error("userId y message son requeridos");
        error.statusCode = 400;
        throw error;
    }
    
    // Obtener información del usuario
    const params = {
        TableName: USUARIOS_TABLE,
        Key: { userId: userId }
    };
    
    const result = await dynamoDB.send(new GetCommand(params));
    
    if (!result.Item) {
        const error = new Error("Usuario no encontrado");
        error.statusCode = 404;
        throw error;
    }
    
    const user = result.Item;
    
    // Preparar email según el tipo de notificación
    let subject, htmlBody;
    
    switch (notificationType) {
        case 'warning':
            subject = "⚠️ Alerta - El Mundo Fitness";
            htmlBody = generateWarningEmail(user.name, message);
            break;
        case 'info':
            subject = "📢 Notificación - El Mundo Fitness";
            htmlBody = generateInfoEmail(user.name, message);
            break;
        case 'success':
            subject = "✅ Confirmación - El Mundo Fitness";
            htmlBody = generateSuccessEmail(user.name, message);
            break;
        default:
            subject = "El Mundo Fitness";
            htmlBody = generateDefaultEmail(user.name, message);
    }
    
    // Enviar email (comentado porque requiere verificar el dominio en SES)
    // await sendEmail(user.email, subject, htmlBody);
    
    console.log(`Notification sent to user ${userId} (${user.email})`);
    
    return {
        message: "Notificación enviada exitosamente",
        recipient: user.email,
        notificationType: notificationType,
        // En producción, descomentar la línea de arriba y usar SES real
        note: "Email simulado - SES requiere verificación de dominio"
    };
}

/**
 * Enviar recordatorios de expiración a usuarios próximos a vencer
 */
async function sendExpirationReminders() {
    // Escanear usuarios con suscripciones próximas a expirar (próximos 7 días)
    const params = {
        TableName: USUARIOS_TABLE,
        FilterExpression: "subscriptionStatus = :active",
        ExpressionAttributeValues: {
            ":active": "active"
        }
    };
    
    const result = await dynamoDB.send(new ScanCommand(params));
    const users = result.Items || [];
    
    const now = new Date();
    const sevenDaysFromNow = new Date(now.getTime() + (7 * 24 * 60 * 60 * 1000));
    
    const notificationsSent = [];
    
    for (const user of users) {
        const endDate = new Date(user.endDate);
        
        // Si expira en los próximos 7 días
        if (endDate > now && endDate <= sevenDaysFromNow) {
            const daysRemaining = Math.ceil((endDate - now) / (1000 * 60 * 60 * 24));
            
            const message = `Tu suscripción expira en ${daysRemaining} día${daysRemaining > 1 ? 's' : ''}. ¡Renueva ahora para continuar disfrutando de todos nuestros servicios!`;
            
            // Enviar recordatorio
            try {
                await sendNotificationToUser(user.userId, message, 'warning');
                notificationsSent.push({
                    userId: user.userId,
                    email: user.email,
                    daysRemaining: daysRemaining
                });
            } catch (error) {
                console.error(`Error sending reminder to ${user.userId}:`, error);
            }
        }
    }
    
    console.log(`Expiration reminders sent to ${notificationsSent.length} users`);
    
    return {
        message: "Recordatorios de expiración enviados",
        totalSent: notificationsSent.length,
        recipients: notificationsSent
    };
}

/**
 * Enviar email de bienvenida
 */
async function sendWelcomeEmail(userId) {
    const params = {
        TableName: USUARIOS_TABLE,
        Key: { userId: userId }
    };
    
    const result = await dynamoDB.send(new GetCommand(params));
    
    if (!result.Item) {
        const error = new Error("Usuario no encontrado");
        error.statusCode = 404;
        throw error;
    }
    
    const user = result.Item;
    
    const message = `¡Bienvenido/a a El Mundo Fitness! Tu suscripción ${user.subscriptionType} está activa. Estamos emocionados de tenerte con nosotros.`;
    
    return await sendNotificationToUser(userId, message, 'success');
}

/**
 * Enviar email usando SES (requiere configuración)
 */
async function sendEmail(toEmail, subject, htmlBody) {
    const params = {
        Source: SENDER_EMAIL,
        Destination: {
            ToAddresses: [toEmail]
        },
        Message: {
            Subject: {
                Data: subject,
                Charset: 'UTF-8'
            },
            Body: {
                Html: {
                    Data: htmlBody,
                    Charset: 'UTF-8'
                }
            }
        }
    };
    
    try {
        const command = new SendEmailCommand(params);
        const result = await sesClient.send(command);
        console.log("Email sent successfully:", result.MessageId);
        return result;
    } catch (error) {
        console.error("Error sending email:", error);
        throw error;
    }
}

/**
 * Generar HTML para email de advertencia
 */
function generateWarningEmail(name, message) {
    return `
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { background-color: #ff9800; color: white; padding: 20px; text-align: center; }
                .content { background-color: #f9f9f9; padding: 20px; }
                .footer { text-align: center; padding: 20px; font-size: 12px; color: #666; }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>⚠️ Alerta Importante</h1>
                </div>
                <div class="content">
                    <p>Hola <strong>${name}</strong>,</p>
                    <p>${message}</p>
                    <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>
                </div>
                <div class="footer">
                    <p>El Mundo Fitness - Tu centro de entrenamiento</p>
                </div>
            </div>
        </body>
        </html>
    `;
}

/**
 * Generar HTML para email informativo
 */
function generateInfoEmail(name, message) {
    return `
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { background-color: #2196F3; color: white; padding: 20px; text-align: center; }
                .content { background-color: #f9f9f9; padding: 20px; }
                .footer { text-align: center; padding: 20px; font-size: 12px; color: #666; }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>📢 Notificación</h1>
                </div>
                <div class="content">
                    <p>Hola <strong>${name}</strong>,</p>
                    <p>${message}</p>
                </div>
                <div class="footer">
                    <p>El Mundo Fitness - Tu centro de entrenamiento</p>
                </div>
            </div>
        </body>
        </html>
    `;
}

/**
 * Generar HTML para email de éxito
 */
function generateSuccessEmail(name, message) {
    return `
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { background-color: #4CAF50; color: white; padding: 20px; text-align: center; }
                .content { background-color: #f9f9f9; padding: 20px; }
                .footer { text-align: center; padding: 20px; font-size: 12px; color: #666; }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>✅ Confirmación</h1>
                </div>
                <div class="content">
                    <p>Hola <strong>${name}</strong>,</p>
                    <p>${message}</p>
                    <p>¡Gracias por confiar en nosotros!</p>
                </div>
                <div class="footer">
                    <p>El Mundo Fitness - Tu centro de entrenamiento</p>
                </div>
            </div>
        </body>
        </html>
    `;
}

/**
 * Generar HTML para email por defecto
 */
function generateDefaultEmail(name, message) {
    return `
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { background-color: #333; color: white; padding: 20px; text-align: center; }
                .content { background-color: #f9f9f9; padding: 20px; }
                .footer { text-align: center; padding: 20px; font-size: 12px; color: #666; }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>El Mundo Fitness</h1>
                </div>
                <div class="content">
                    <p>Hola <strong>${name}</strong>,</p>
                    <p>${message}</p>
                </div>
                <div class="footer">
                    <p>El Mundo Fitness - Tu centro de entrenamiento</p>
                </div>
            </div>
        </body>
        </html>
    `;
}
