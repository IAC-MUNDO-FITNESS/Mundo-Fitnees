// ============================================
// Tests unitarios: Subscription Control Lambda
// ============================================

const { mockClient } = require('aws-sdk-client-mock');
const { DynamoDBDocumentClient, GetCommand, PutCommand, UpdateCommand } = require("@aws-sdk/lib-dynamodb");

const ddbMock = mockClient(DynamoDBDocumentClient);

const subscriptionControl = require('../lambda-code-examples/subscription-control');

describe('Subscription Control Lambda Tests', () => {
    
    beforeEach(() => {
        ddbMock.reset();
        process.env.USUARIOS_TABLE = 'test-usuarios-table';
        process.env.AWS_REGION = 'us-east-1';
    });

    describe('Handler - Create Subscription', () => {
        test('debe crear nueva subscripción', async () => {
            ddbMock.on(GetCommand).resolves({ Item: undefined });
            ddbMock.on(PutCommand).resolves({});

            const event = {
                body: JSON.stringify({
                    action: 'create',
                    userId: 'newuser123',
                    nombre: 'New User',
                    email: 'newuser@example.com',
                    planId: 'monthly'
                })
            };

            const result = await subscriptionControl.handler(event);
            
            expect(result.statusCode).toBe(200);
            const body = JSON.parse(result.body);
            expect(body.success).toBe(true);
        });

        test('debe rechazar creación de subscripción duplicada', async () => {
            ddbMock.on(GetCommand).resolves({
                Item: { userId: 'existinguser' }
            });

            const event = {
                body: JSON.stringify({
                    action: 'create',
                    userId: 'existinguser',
                    nombre: 'Existing User',
                    email: 'existing@example.com'
                })
            };

            const result = await subscriptionControl.handler(event);
            
            expect(result.statusCode).toBe(400);
            const body = JSON.parse(result.body);
            expect(body.success).toBe(false);
        });
    });

    describe('Handler - Renew Subscription', () => {
        test('debe renovar subscripción exitosamente', async () => {
            const currentDate = new Date();
            ddbMock.on(GetCommand).resolves({
                Item: {
                    userId: 'user123',
                    subscripcionActiva: true,
                    fechaVencimiento: currentDate.toISOString()
                }
            });
            ddbMock.on(UpdateCommand).resolves({});

            const event = {
                body: JSON.stringify({
                    action: 'renew',
                    userId: 'user123',
                    planId: 'monthly'
                })
            };

            const result = await subscriptionControl.handler(event);
            
            expect(result.statusCode).toBe(200);
            const body = JSON.parse(result.body);
            expect(body.success).toBe(true);
        });
    });

    describe('Handler - Cancel Subscription', () => {
        test('debe cancelar subscripción', async () => {
            ddbMock.on(GetCommand).resolves({
                Item: {
                    userId: 'user456',
                    subscripcionActiva: true
                }
            });
            ddbMock.on(UpdateCommand).resolves({});

            const event = {
                body: JSON.stringify({
                    action: 'cancel',
                    userId: 'user456'
                })
            };

            const result = await subscriptionControl.handler(event);
            
            expect(result.statusCode).toBe(200);
            const body = JSON.parse(result.body);
            expect(body.success).toBe(true);
        });
    });

    describe('Handler - Get Subscription', () => {
        test('debe obtener información de subscripción', async () => {
            ddbMock.on(GetCommand).resolves({
                Item: {
                    userId: 'user789',
                    nombre: 'Test User',
                    email: 'test@example.com',
                    subscripcionActiva: true,
                    planId: 'monthly',
                    fechaVencimiento: new Date().toISOString()
                }
            });

            const event = {
                body: JSON.stringify({
                    action: 'get',
                    userId: 'user789'
                })
            };

            const result = await subscriptionControl.handler(event);
            
            expect(result.statusCode).toBe(200);
            const body = JSON.parse(result.body);
            expect(body.success).toBe(true);
            expect(body.data.userId).toBe('user789');
        });

        test('debe manejar subscripción no encontrada', async () => {
            ddbMock.on(GetCommand).resolves({ Item: undefined });

            const event = {
                body: JSON.stringify({
                    action: 'get',
                    userId: 'nonexistent'
                })
            };

            const result = await subscriptionControl.handler(event);
            
            expect(result.statusCode).toBe(404);
            const body = JSON.parse(result.body);
            expect(body.success).toBe(false);
        });
    });

    describe('Validación de datos', () => {
        test('debe validar campos requeridos para crear subscripción', async () => {
            const event = {
                body: JSON.stringify({
                    action: 'create',
                    userId: 'user123'
                    // faltan nombre y email
                })
            };

            const result = await subscriptionControl.handler(event);
            
            expect(result.statusCode).toBe(400);
            const body = JSON.parse(result.body);
            expect(body.success).toBe(false);
        });

        test('debe validar formato de email', async () => {
            ddbMock.on(GetCommand).resolves({ Item: undefined });

            const event = {
                body: JSON.stringify({
                    action: 'create',
                    userId: 'user123',
                    nombre: 'Test',
                    email: 'invalid-email'
                })
            };

            const result = await subscriptionControl.handler(event);
            
            expect(result.statusCode).toBe(400);
            const body = JSON.parse(result.body);
            expect(body.success).toBe(false);
        });
    });
});

console.log('✓ Subscription Control tests loaded');
