// ============================================
// Lambda Function: Subscription Control
// Gestión de suscripciones de usuarios
// ============================================

const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand, GetCommand, UpdateCommand, QueryCommand } = require("@aws-sdk/lib-dynamodb");

// Configurar cliente DynamoDB
const client = new DynamoDBClient({ region: process.env.AWS_REGION || "us-east-1" });
const dynamoDB = DynamoDBDocumentClient.from(client);

const USUARIOS_TABLE = process.env.USUARIOS_TABLE || "elmundo-fitness-usuarios-dev";

/**
 * Handler principal de Lambda
 */
exports.handler = async (event) => {
    console.log("Event received:", JSON.stringify(event, null, 2));
    
    try {
        // Parsear el body de la petición
        const body = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;
        
        // Determinar la acción según el método HTTP o el body
        const httpMethod = event.requestContext?.http?.method || event.httpMethod || 'POST';
        
        let result;
        
        switch (httpMethod) {
            case 'POST':
                result = await createSubscription(body);
                break;
            case 'GET':
                const userId = event.pathParameters?.userId || body.userId;
                result = await getSubscription(userId);
                break;
            case 'PUT':
                result = await updateSubscription(body);
                break;
            default:
                throw new Error(`Método no soportado: ${httpMethod}`);
        }
        
        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'GET, POST, PUT, OPTIONS',
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
 * Crear nueva suscripción
 */
async function createSubscription(data) {
    const { userId, email, name, subscriptionType, startDate } = data;
    
    // Validar datos requeridos
    if (!userId || !email || !subscriptionType) {
        const error = new Error("Faltan datos requeridos: userId, email, subscriptionType");
        error.statusCode = 400;
        throw error;
    }
    
    // Calcular fecha de expiración según el tipo de suscripción
    const start = startDate ? new Date(startDate) : new Date();
    let endDate = new Date(start);
    
    switch (subscriptionType.toLowerCase()) {
        case 'monthly':
            endDate.setMonth(endDate.getMonth() + 1);
            break;
        case 'quarterly':
            endDate.setMonth(endDate.getMonth() + 3);
            break;
        case 'annual':
            endDate.setFullYear(endDate.getFullYear() + 1);
            break;
        default:
            const error = new Error("Tipo de suscripción inválido");
            error.statusCode = 400;
            throw error;
    }
    
    // Crear registro en DynamoDB
    const params = {
        TableName: USUARIOS_TABLE,
        Item: {
            userId: userId,
            email: email,
            name: name || '',
            subscriptionType: subscriptionType,
            subscriptionStatus: 'active',
            startDate: start.toISOString(),
            endDate: endDate.toISOString(),
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        }
    };
    
    await dynamoDB.send(new PutCommand(params));
    
    console.log("Subscription created successfully for user:", userId);
    
    return {
        message: "Suscripción creada exitosamente",
        subscription: params.Item
    };
}

/**
 * Obtener información de suscripción
 */
async function getSubscription(userId) {
    if (!userId) {
        const error = new Error("userId es requerido");
        error.statusCode = 400;
        throw error;
    }
    
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
    
    // Verificar si la suscripción está activa
    const now = new Date();
    const endDate = new Date(result.Item.endDate);
    const isActive = now <= endDate && result.Item.subscriptionStatus === 'active';
    
    return {
        user: result.Item,
        isActive: isActive,
        daysRemaining: isActive ? Math.ceil((endDate - now) / (1000 * 60 * 60 * 24)) : 0
    };
}

/**
 * Actualizar suscripción
 */
async function updateSubscription(data) {
    const { userId, subscriptionType, subscriptionStatus } = data;
    
    if (!userId) {
        const error = new Error("userId es requerido");
        error.statusCode = 400;
        throw error;
    }
    
    // Preparar expresiones de actualización
    let updateExpression = "SET updatedAt = :updatedAt";
    let expressionAttributeValues = {
        ":updatedAt": new Date().toISOString()
    };
    
    if (subscriptionType) {
        updateExpression += ", subscriptionType = :subscriptionType";
        expressionAttributeValues[":subscriptionType"] = subscriptionType;
    }
    
    if (subscriptionStatus) {
        updateExpression += ", subscriptionStatus = :subscriptionStatus";
        expressionAttributeValues[":subscriptionStatus"] = subscriptionStatus;
    }
    
    const params = {
        TableName: USUARIOS_TABLE,
        Key: { userId: userId },
        UpdateExpression: updateExpression,
        ExpressionAttributeValues: expressionAttributeValues,
        ReturnValues: "ALL_NEW"
    };
    
    const result = await dynamoDB.send(new UpdateCommand(params));
    
    console.log("Subscription updated successfully for user:", userId);
    
    return {
        message: "Suscripción actualizada exitosamente",
        subscription: result.Attributes
    };
}
