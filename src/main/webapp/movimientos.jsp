<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.dolcevida.model.Producto"%>
<%@page import="org.hibernate.Session"%>
<%@page import="com.dolcevida.util.HibernateUtil"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dolce Vida - Registrar Movimiento</title>
    <link href="css/bootstrap.css" rel="stylesheet">
    <style>
        body { background-color: #f4f6f9; font-family: 'Segoe UI', sans-serif; }
        .navbar-custom { background-color: #ff6f91; display: flex; align-items: center; justify-content: space-between; }
        .navbar-nav { display: flex; flex-direction: row; list-style: none; margin: 0; padding: 0; gap: 20px; }
        .nav-link { color: white !important; text-decoration: none; padding: 8px 15px; font-weight: 600; display: inline-block; }
        .nav-link:hover { background-color: rgba(255,255,255,0.2); border-radius: 8px; }
        .form-container { background: white; padding: 30px; border-radius: 15px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
    </style>
</head>
<body>

    <!-- MENÚ SUPERIOR -->
    <nav class="navbar navbar-custom p-3 shadow">
        <div class="container-fluid d-flex align-items-center justify-content-between" style="display: flex; width: 100%; justify-content: space-between; align-items: center;">
            <a class="navbar-brand fw-bold fs-4 text-white text-decoration-none" href="principal.jsp">🍬 Dolce Vida Web</a>
            <ul class="navbar-nav">
                <li><a class="nav-link" href="principal.jsp">Inicio</a></li>
                <li><a class="nav-link" href="ProductoController">Inventario</a></li>
                <li><a class="nav-link" href="movimientos.jsp">Bodega</a></li>
                <li><a class="nav-link" href="facturacion.jsp">Caja/Ventas</a></li>
            </ul>
        </div>
    </nav>

    <div class="container mt-5">
        <div class="row justify-content-center" style="display: flex; justify-content: center;">
            <div class="col-md-6" style="width: 50%;">
                <div class="form-container">
                    <h3 class="fw-bold mb-4 text-secondary">📦 Registrar Entrada / Salida</h3>
                    
                    <form action="MovimientoController" method="POST">
                        <div class="mb-3" style="margin-bottom: 15px;">
                            <label class="form-label text-muted fw-semibold">Seleccionar Producto</label>
                            <select class="form-select" name="idProducto" required style="display: block; width: 100%; padding: 8px;">
                                <option value="">-- Elige un dulce o snack --</option>
                                <%
                                    Session hSession = HibernateUtil.getSessionFactory().openSession();
                                    List<Producto> lista = hSession.createQuery("FROM Producto", Producto.class).list();
                                    for(Producto p : lista) {
                                %>
                                    <option value="<%= p.getIdProducto() %>"><%= p.getNombre() %> (Stock: <%= p.getCantidad() %>)</option>
                                <%
                                    }
                                    hSession.close();
                                %>
                            </select>
                        </div>

                        <div class="mb-3" style="margin-bottom: 15px;">
                            <label class="form-label text-muted fw-semibold">Tipo de Movimiento</label>
                            <select class="form-select" name="tipoMovimiento" required style="display: block; width: 100%; padding: 8px;">
                                <option value="ENTRADA">📥 ENTRADA (Surtir Bodega / Compra)</option>
                                <option value="SALIDA">📤 SALIDA (Venta / Merma / Vencido)</option>
                                <option value="AJUSTE">🔄 AJUSTE (Corrección de inventario)</option>
                            </select>
                        </div>

                        <div class="mb-3" style="margin-bottom: 15px;">
                            <label class="form-label text-muted fw-semibold">Cantidad de Unidades</label>
                            <input type="number" class="form-control" name="cantidad" min="1" placeholder="Ej: 10" required style="display: block; width: 100%; padding: 8px;">
                        </div>

                        <div class="mb-4" style="margin-bottom: 20px;">
                            <label class="form-label text-muted fw-semibold">Observación / Nota</label>
                            <input type="text" class="form-control" name="observacion" placeholder="Ej: Surtido de proveedor" style="display: block; width: 100%; padding: 8px;">
                        </div>

                        <button type="submit" class="btn w-100 py-2 fw-bold text-white" style="background-color: #ff6f91; border: none; width: 100%; padding: 10px;">
                            Guardar Movimiento en Bodega 💾
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

</body>
</html>
