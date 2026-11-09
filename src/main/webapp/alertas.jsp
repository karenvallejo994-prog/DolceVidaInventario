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
    <title>Dolce Vida - Alertas del Sistema</title>
    <link href="css/bootstrap.css" rel="stylesheet">
    <style>
        body { background-color: #f4f6f9; font-family: 'Segoe UI', sans-serif; margin: 0; padding: 0; }
        .sidebar { background-color: #4a2834; min-height: 100vh; color: white; padding-top: 20px; position: fixed; width: 240px; z-index: 100; }
        .sidebar-brand { font-size: 1.5rem; font-weight: bold; padding: 10px 20px; line-height: 1.2; }
        .sidebar-subtitle { font-size: 0.8rem; color: #bca0aa; padding: 0 20px 20px 20px; border-bottom: 1px solid #5c3845; }
        .nav-menu { list-style: none; padding: 20px 0; margin: 0; }
        .nav-item-link { color: #dcbcc6; text-decoration: none; padding: 12px 25px; display: flex; align-items: center; gap: 12px; font-weight: 500; transition: all 0.2s; }
        .nav-item-link:hover, .nav-item-link.active { color: white; background-color: rgba(255,255,255,0.1); border-left: 4px solid #ff6f91; }
        .main-content { margin-left: 240px; padding: 40px; }
        .alert-container { background: white; border-radius: 15px; padding: 30px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); }
        .panel-warning-custom { border-left: 5px solid #dc3545 !important; background-color: #fff8f8; border-radius: 10px; padding: 15px; margin-bottom: 20px; }
    </style>
</head>
<body>

    <!-- MENÚ LATERAL DE NAVEGACION -->
    <div class="sidebar">
        <div class="sidebar-brand">Dolce Vida</div>
        <div class="sidebar-subtitle">Sistema de Inventario</div>
        <ul class="nav-menu">
            <li><a href="${pageContext.request.contextPath}/principal.jsp" class="nav-item-link">🏠 Inicio</a></li>
            <li><a href="${pageContext.request.contextPath}/ProductoController" class="nav-item-link">📦 Inventario</a></li>
            <li><a href="${pageContext.request.contextPath}/categorias.jsp" class="nav-item-link">📁 Categorías</a></li>
            <li><a href="${pageContext.request.contextPath}/alertas.jsp" class="nav-item-link active">⚠️ Alertas</a></li>
            <li><a href="${pageContext.request.contextPath}/facturacion.jsp" class="nav-item-link">🧾 Facturación</a></li>
            <li><a href="${pageContext.request.contextPath}/reportes.jsp" class="nav-item-link">📊 Reportes</a></li>
            <li class="mt-5"><a href="${pageContext.request.contextPath}/index.html" class="nav-item-link" style="color: #ff8fa3;">🚪 Cerrar sesión</a></li>
        </ul>
    </div>

    <!-- CONTENIDO PRINCIPAL -->
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold text-dark m-0" style="font-weight: bold; font-size: 1.8rem;">Alertas del sistema</h2>
                <small class="text-muted">Detección automática de stock crítico o mermas</small>
            </div>
        </div>

        <div class="alert-container">
            <div class="panel-warning-custom">
                <h5 class="fw-bold text-danger m-0">🚨 Control de Abastecimiento Crítico</h5>
                <small class="text-muted">A continuación se listan los dulces que requieren pedido inmediato a proveedores para evitar quiebre de stock.</small>
            </div>

            <table class="table table-hover align-middle" style="width: 100%;">
                <thead style="background-color: #f8f9fa; color: #6c757d; font-weight: 600;">
                    <tr>
                        <th style="padding: 12px;">Código</th>
                        <th style="padding: 12px;">Producto</th>
                        <th style="padding: 12px;">Stock Mínimo</th>
                        <th style="padding: 12px;">Cantidad Real</th>
                        <th style="padding: 12px;">Nivel de Riesgo</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        Session hSession = HibernateUtil.getSessionFactory().openSession();
                        List<Producto> alertasStock = hSession.createQuery("FROM Producto WHERE cantidad < 20", Producto.class).list();
                        if (alertasStock != null && !alertasStock.isEmpty()) {
                            for (Producto p : alertasStock) {
                    %>
                    <tr style="border-bottom: 1px solid #eee;">
                        <td style="padding: 12px; color: #6c757d;">DV00<%= p.getIdProducto() %></td>
                        <td style="padding: 12px; font-weight: bold; color: #333;"><%= p.getNombre() %></td>
                        <td style="padding: 12px; color: #6c757d;">20 unidades</td>
                        <td style="padding: 12px; font-weight: bold; color: #dc3545;"><%= p.getCantidad() %> unidades</td>
                        <td style="padding: 12px;">
                            <span class="badge bg-danger" style="padding: 6px 12px; border-radius: 20px; color: white; font-weight: bold;">
                                Crítico 🛑
                            </span>
                        </td>
                    </tr>
                    <%
                            }
                        } else {
                    %>
                    <tr>
                        <td colspan="5" class="text-center text-muted py-4">✅ Todo el inventario se encuentra correctamente abastecido.</td>
                    </tr>
                    <%
                        }
                        hSession.close();
                    %>
                </tbody>
            </table>
        </div>
    </div>

</body>
</html>
