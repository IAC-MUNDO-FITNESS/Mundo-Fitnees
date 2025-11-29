// ============================================
// Lambda Function: Access Control
// Control de acceso y registro de asistencia
// ============================================

const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand, PutCommand, QueryCommand } = require("@aws-sdk/lib-dynamodb");
const { v4: uuidv4 } = require('uuid');

// Configurar cliente DynamoDB
const client = new DynamoDBClient({ region: process.env.AWS_REGION || "us-east-1" });
const dynamoDB = DynamoDBDocumentClient.from(client);

const USUARIOS_TABLE = process.env.USUARIOS_TABLE || "elmundo-fitness-usuarios-dev";
const HISTORIAL_TABLE = process.env.HISTORIAL_TABLE || "elmundo-fitness-historial-asistencia-dev";

/**
 * Handler principal de Lambda
 */
exports.handler = async (event) => {
    console.log("Event received:", JSON.stringify(event, null, 2));
    
    try {
        // Parsear el body de la petición
        const body = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;
        
        const { userId, action } = body;
        
        // Validar datos requeridos
        if (!userId) {
            throw new Error("userId es requerido");
        }
        
        let result;
        
        switch (action) {
            case 'check-in':
                result = await checkIn(userId);
                break;
            case 'check-out':
                result = await checkOut(userId);
                break;
            case 'verify-access':
                result = await verifyAccess(userId);
                break;
            case 'get-history':
                result = await getHistory(userId, body.limit || 10);
                break;
            default:
                result = await checkIn(userId); // Por defecto, check-in
        }
        
        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
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
 * Verificar si el usuario tiene acceso activo
 */
async function verifyAccess(userId) {
    // Obtener información del usuario
    const params = {
        TableName: USUARIOS_TABLE,
        Key: { userId: userId }
    };
    
    const result = await dynamoDB.send(new GetCommand(params));
    
    if (!result.Item) {
        return {
            hasAccess: false,
            reason: "Usuario no encontrado"
        };
    }
    
    const user = result.Item;
    
    // Verificar si la suscripción está activa
    const now = new Date();
    const endDate = new Date(user.endDate);
    
    if (user.subscriptionStatus !== 'active') {
        return {
            hasAccess: false,
            reason: "Suscripción inactiva",
            user: {
                userId: user.userId,
                name: user.name,
                subscriptionStatus: user.subscriptionStatus
            }
        };
    }
    
    if (now > endDate) {
        return {
            hasAccess: false,
            reason: "Suscripción expirada",
            user: {
                userId: user.userId,
                name: user.name,
                endDate: user.endDate
            }
        };
    }
    
    // Calcular días restantes
    const daysRemaining = Math.ceil((endDate - now) / (1000 * 60 * 60 * 24));
    
    return {
        hasAccess: true,
        user: {
            userId: user.userId,
            name: user.name,
            email: user.email,
            subscriptionType: user.subscriptionType,
            endDate: user.endDate,
            daysRemaining: daysRemaining
        }
    };
}

/**
 * Registrar entrada (check-in)
 */
async function checkIn(userId) {
    // Verificar acceso primero
    const accessCheck = await verifyAccess(userId);
    
    if (!accessCheck.hasAccess) {
        const error = new Error(`Acceso denegado: ${accessCheck.reason}`);
        error.statusCode = 403;
        throw error;
    }
    
    // Registrar entrada en historial
    const asistenciaId = uuidv4();
    const timestamp = Date.now();
    
    const params = {
        TableName: HISTORIAL_TABLE,
        Item: {
            asistenciaId: asistenciaId,
            userId: userId,
            timestamp: timestamp,
            action: 'check-in',
            checkInTime: new Date().toISOString(),
            userName: accessCheck.user.name,
            userEmail: accessCheck.user.email
        }
    };
    
    await dynamoDB.send(new PutCommand(params));
    
    console.log("Check-in registered for user:", userId);
    
    return {
        message: `¡Bienvenido/a ${accessCheck.user.name}!`,
        action: 'check-in',
        timestamp: new Date().toISOString(),
        user: accessCheck.user,
        asistenciaId: asistenciaId
    };
}

/**
 * Registrar salida (check-out)
 */
async function checkOut(userId) {
    const asistenciaId = uuidv4();
    const timestamp = Date.now();
    
    const params = {
        TableName: HISTORIAL_TABLE,
        Item: {
            asistenciaId: asistenciaId,
            userId: userId,
            timestamp: timestamp,
            action: 'check-out',
            checkOutTime: new Date().toISOString()
        }
    };
    
    await dynamoDB.send(new PutCommand(params));
    
    console.log("Check-out registered for user:", userId);
    
    return {
        message: "¡Hasta pronto!",
        action: 'check-out',
        timestamp: new Date().toISOString(),
        asistenciaId: asistenciaId
    };
}

/**
 * Obtener historial de asistencia
 */
async function getHistory(userId, limit = 10) {
    const params = {
        TableName: HISTORIAL_TABLE,
        IndexName: "UserIdIndex",
        KeyConditionExpression: "userId = :userId",
        ExpressionAttributeValues: {
            ":userId": userId
        },
        Limit: limit,
        ScanIndexForward: false // Orden descendente (más recientes primero)
    };
    
    const result = await dynamoDB.send(new QueryCommand(params));
    
    return {
        userId: userId,
        totalRecords: result.Items?.length || 0,
        history: result.Items || []
    };
}
