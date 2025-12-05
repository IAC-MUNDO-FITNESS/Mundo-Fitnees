// ============================================
// Tests unitarios: Notification Service Lambda
// ============================================

const { mockClient } = require('aws-sdk-client-mock');
const { DynamoDBDocumentClient, GetCommand, ScanCommand } = require("@aws-sdk/lib-dynamodb");
const { SESClient, SendEmailCommand } = require("@aws-sdk/client-ses");

// Mock de los clientes
const ddbMock = mockClient(DynamoDBDocumentClient);
const sesMock = mockClient(SESClient);

// Importar el handler
const notificationService = require('../lambda-code-examples/notification-service');

describe('Notification Service Lambda Tests', () => {
    
    beforeEach(() => {
        // Limpiar mocks
        ddbMock.reset();
        sesMock.reset();
        
        // Configurar variables de entorno
        process.env.USUARIOS_TABLE = 'test-usuarios-table';
        process.env.SENDER_EMAIL = 'test@elmundofitness.com';
        process.env.AWS_REGION = 'us-east-1';
    });

    describe('Handler - Send to User', () => {
        test('debe enviar email exitosamente a usuario existente', async () => {
            // Mock DynamoDB - obtener usuario
            ddbMock.on(GetCommand).resolves({
                Item: {
                    userId: 'user123',
                    nombre: 'Test User',
                    email: 'testuser@example.com',
                    subscripcionActiva: true
                }
            });

            // Mock SES - enviar email
            sesMock.on(SendEmailCommand).resolves({
                MessageId: 'test-message-id-123'
            });

            const event = {
                body: JSON.stringify({
                    action: 'send-to-user',
                    userId: 'user123',
                    message: 'Test notification',
                    notificationType: 'info'
                })
            };

            const result = await notificationService.handler(event);
            
            expect(result.statusCode).toBe(200);
            const body = JSON.parse(result.body);
            expect(body.success).toBe(true);
            expect(body.data.sent).toBe(true);
        });

        test('debe manejar usuario no encontrado', async () => {
            ddbMock.on(GetCommand).resolves({ Item: undefined });

            const event = {
                body: JSON.stringify({
                    action: 'send-to-user',
                    userId: 'nonexistent',
                    message: 'Test'
                })
            };

            const result = await notificationService.handler(event);
            
            expect(result.statusCode).toBe(404);
            const body = JSON.parse(result.body);
            expect(body.success).toBe(false);
        });
    });

    describe('Handler - Welcome Email', () => {
        test('debe enviar email de bienvenida', async () => {
            ddbMock.on(GetCommand).resolves({
                Item: {
                    userId: 'newuser',
                    nombre: 'New User',
                    email: 'newuser@example.com'
                }
            });

            sesMock.on(SendEmailCommand).resolves({
                MessageId: 'welcome-message-id'
            });

            const event = {
                body: JSON.stringify({
                    action: 'send-welcome',
                    userId: 'newuser'
                })
            };

            const result = await notificationService.handler(event);
            
            expect(result.statusCode).toBe(200);
            const body = JSON.parse(result.body);
            expect(body.success).toBe(true);
        });
    });

    describe('Handler - Expiration Reminders', () => {
        test('debe enviar recordatorios de expiración', async () => {
            // Mock Scan - usuarios próximos a vencer
            const nextWeek = new Date();
            nextWeek.setDate(nextWeek.getDate() + 5);

            ddbMock.on(ScanCommand).resolves({
                Items: [
                    {
                        userId: 'user1',
                        nombre: 'User One',
                        email: 'user1@example.com',
                        fechaVencimiento: nextWeek.toISOString(),
                        subscripcionActiva: true
                    },
                    {
                        userId: 'user2',
                        nombre: 'User Two',
                        email: 'user2@example.com',
                        fechaVencimiento: nextWeek.toISOString(),
                        subscripcionActiva: true
                    }
                ]
            });

            sesMock.on(SendEmailCommand).resolves({
                MessageId: 'reminder-message-id'
            });

            const event = {
                body: JSON.stringify({
                    action: 'send-expiration-reminders'
                })
            };

            const result = await notificationService.handler(event);
            
            expect(result.statusCode).toBe(200);
            const body = JSON.parse(result.body);
            expect(body.success).toBe(true);
            expect(body.data.remindersSent).toBeGreaterThanOrEqual(0);
        });
    });

    describe('Validación de entradas', () => {
        test('debe rechazar action no soportada', async () => {
            const event = {
                body: JSON.stringify({
                    action: 'invalid-action'
                })
            };

            const result = await notificationService.handler(event);
            
            expect(result.statusCode).toBe(500);
            const body = JSON.parse(result.body);
            expect(body.success).toBe(false);
            expect(body.error).toContain('no soportada');
        });

        test('debe validar campos requeridos para send-to-user', async () => {
            const event = {
                body: JSON.stringify({
                    action: 'send-to-user',
                    userId: 'user123'
                    // falta message
                })
            };

            const result = await notificationService.handler(event);
            
            expect(result.statusCode).toBe(400);
            const body = JSON.parse(result.body);
            expect(body.success).toBe(false);
        });
    });

    describe('Error handling', () => {
        test('debe manejar errores de SES', async () => {
            ddbMock.on(GetCommand).resolves({
                Item: {
                    userId: 'user123',
                    email: 'test@example.com'
                }
            });

            sesMock.on(SendEmailCommand).rejects(new Error('SES Error'));

            const event = {
                body: JSON.stringify({
                    action: 'send-to-user',
                    userId: 'user123',
                    message: 'Test'
                })
            };

            const result = await notificationService.handler(event);
            
            expect(result.statusCode).toBe(500);
            const body = JSON.parse(result.body);
            expect(body.success).toBe(false);
        });
    });
});

console.log('✓ Notification Service tests loaded');
