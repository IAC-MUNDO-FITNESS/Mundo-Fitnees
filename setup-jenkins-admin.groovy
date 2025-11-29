import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()

// Crear usuario admin si no existe
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin", "admin")
instance.setSecurityRealm(hudsonRealm)

// Dar permisos completos al usuario admin
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

instance.save()

println "Usuario 'admin' creado con contraseña 'admin'"
println "Accede a Jenkins en: http://localhost:8080"
