<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dolce Vida - Registro de Usuarios</title>
    <link href="css/bootstrap.css" rel="stylesheet">
    <style>
        body { background-color: #f4f6f9; font-family: 'Segoe UI', sans-serif; }
        .register-container { max-width: 450px; margin-top: 80px; }
        .card-register { border: none; border-radius: 15px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
    </style>
</head>
<body class="d-flex justify-content-center align-items-center">

    <div class="container register-container">
        <div class="card card-register p-4 bg-white">
            <div class="text-center mb-4">
                <h3 class="fw-bold text-dark m-0">🍬 Dolce Vida</h3>
                <small class="text-muted">Servicio Web de Registro de Personal</small>
            </div>
            
            <!-- El formulario envía los datos mediante POST al Servicio Web (Servlet) -->
            <form action="RegistroController" method="POST">
                <div class="mb-3">
                    <label class="form-label text-muted fw-semibold">Nombre Completo</label>
                    <input type="text" class="form-control" name="nombre" placeholder="Ej: Sonia Vallejo" required>
                </div>
                <div class="mb-3">
                    <label class="form-label text-muted fw-semibold">Nombre de Usuario</label>
                    <input type="text" class="form-control" name="usuario" placeholder="Ej: sonia_vallejo" required>
                </div>
                <div class="mb-3">
                    <label class="form-label text-muted fw-semibold">Contraseña del Sistema</label>
                    <input type="password" class="form-control" name="contrasena" placeholder="Mínimo 6 caracteres" required>
                </div>
                <div class="mb-4">
                    <label class="form-label text-muted fw-semibold">Rol Asignado</label>
                    <select class="form-select" name="rol" required>
                        <option value="Administrador">Administrador</option>
                        <option value="Empleado">Empleado / Cajero</option>
                    </select>
                </div>
                
                <button type="submit" class="btn text-white w-100 py-2 fw-bold" style="background-color: #4a2834; border: none;">
                    Crear Cuenta de Usuario 🔐
                </button>
                
                <div class="text-center mt-3">
                    <a href="index.html" class="text-decoration-none small" style="color: #ff6f91;">Regresar al Login</a>
                </div>
            </form>
        </div>
    </div>

</body>
</html>
