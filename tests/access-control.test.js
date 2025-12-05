// ============================================
// Tests unitarios: Access Control Lambda
// ============================================

const { mockClient } = require('aws-sdk-client-mock');
const { DynamoDBDocumentClient, GetCommand, PutCommand } = require("@aws-sdk/lib-dynamodb");

// Mock del cliente DynamoDB
const ddbMock = mockClient(DynamoDBDocumentClient);

// Importar el handler (simularemos la exportación)
const accessControl = require('../lambda-code-examples/access-control');

describe('Access Control Lambda Tests', () => {
    
    beforeEach(() => {
        // Limpiar mocks antes de cada test
        ddbMock.reset();
        
        // Configurar variables de entorno
        process.env.USUARIOS_TABLE = 'test-usuarios-table';
        process.env.HISTORIAL_TABLE = 'test-historial-table';
        process.env.AWS_REGION = 'us-east-1';
    });

    describe('Handler - Verify Access', () => {
        test('debe verificar acceso exitoso para usuario activo', async () => {
            // Mock de respuesta de DynamoDB
            ddbMock.on(GetCommand).resolves({
                Item: {
                    userId: 'user123',
                    nombre: 'Test User',
                    email: 'test@test.com',
                    subscripcionActiva: true,
                    fechaVencimiento: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString()
                }
            });

            const event = {
                body: JSON.stringify({
                    userId: 'user123',
                    action: 'verify-access'
                })
            };

            const result = await accessControl.handler(event);
            
            expect(result.statusCode).toBe(200);
            const body = JSON.parse(result.body);
            expect(body.success).toBe(true);
            expect(body.data.hasAccess).toBe(true);
        });

        test('debe denegar acceso para usuario sin subscripción', async () => {
            ddbMock.on(GetCommand).resolves({
                Item: {
                    userId: 'user456',
                    nombre: 'Inactive User',
                    subscripcionActiva: false
                }
            });

            const event = {
                body: JSON.stringify({
                    userId: 'user456',
                    action: 'verify-access'
                })
            };

            const result = await accessControl.handler(event);
            
            expect(result.statusCode).toBe(200);
            const body = JSON.parse(result.body);
            expect(body.data.hasAccess).toBe(false);
        });

        test('debe manejar usuario no encontrado', async () => {
            ddbMock.on(GetCommand).resolves({ Item: undefined });

            const event = {
                body: JSON.stringify({
                    userId: 'nonexistent',
                    action: 'verify-access'
                })
            };

            const result = await accessControl.handler(event);
            
            expect(result.statusCode).toBe(200);
            const body = JSON.parse(result.body);
            expect(body.data.hasAccess).toBe(false);
        });
    });

    describe('Handler - Check In', () => {
        test('debe registrar check-in exitoso', async () => {
            ddbMock.on(GetCommand).resolves({
                Item: {
                    userId: 'user789',
                    subscripcionActiva: true
                }
            });
            ddbMock.on(PutCommand).resolves({});

            const event = {
                body: JSON.stringify({
                    userId: 'user789',
                    action: 'check-in'
                })
            };

            const result = await accessControl.handler(event);
            
            expect(result.statusCode).toBe(200);
            const body = JSON.parse(result.body);
            expect(body.success).toBe(true);
        });
    });

    describe('Validación de entradas', () => {
        test('debe rechazar request sin userId', async () => {
            const event = {
                body: JSON.stringify({
                    action: 'verify-access'
                })
            };

            const result = await accessControl.handler(event);
            
            expect(result.statusCode).toBe(500);
            const body = JSON.parse(result.body);
            expect(body.success).toBe(false);
            expect(body.error).toContain('userId');
        });

        test('debe manejar body malformado', async () => {
            const event = {
                body: 'invalid json'
            };

            const result = await accessControl.handler(event);
            
            expect(result.statusCode).toBe(500);
            const body = JSON.parse(result.body);
            expect(body.success).toBe(false);
        });
    });

    describe('CORS Headers', () => {
        test('debe incluir headers CORS en respuesta exitosa', async () => {
            ddbMock.on(GetCommand).resolves({
                Item: { userId: 'user123', subscripcionActiva: true }
            });

            const event = {
                body: JSON.stringify({
                    userId: 'user123',
                    action: 'verify-access'
                })
            };

            const result = await accessControl.handler(event);
            
            expect(result.headers['Access-Control-Allow-Origin']).toBe('*');
            expect(result.headers['Content-Type']).toBe('application/json');
        });
    });
});

console.log('✓ Access Control tests loaded');
