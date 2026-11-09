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
    <title>Dolce Vida - Panel Principal</title>
    <link href="css/bootstrap.css" rel="stylesheet">
    <style>
        body { background-color: #f4f6f9; font-family: 'Segoe UI', sans-serif; margin: 0; padding: 0; }
        .sidebar { background-color: #4a2834; min-height: 100vh; color: white; padding-top: 20px; position: fixed; width: 240px; }
        .sidebar-brand { font-size: 1.5rem; font-weight: bold; padding: 10px 20px; line-height: 1.2; }
        .sidebar-subtitle { font-size: 0.8rem; color: #bca0aa; padding: 0 20px 20px 20px; border-bottom: 1px solid #5c3845; }
        .nav-menu { list-style: none; padding: 20px 0; margin: 0; }
        .nav-item-link { color: #dcbcc6; text-decoration: none; padding: 12px 25px; display: flex; align-items: center; gap: 12px; font-weight: 500; transition: all 0.2s; }
        .nav-item-link:hover, .nav-item-link.active { color: white; background-color: rgba(255,255,255,0.1); border-left: 4px solid #ff6f91; }
        .main-content { margin-left: 240px; padding: 40px; }
        .stat-card { background: white; border-radius: 15px; border: none; box-shadow: 0 4px 15px rgba(0,0,0,0.03); padding: 20px; position: relative; }
        .stat-card-warning { border-left: 4px solid #ffc107 !important; }
        .table-container { background: white; border-radius: 15px; padding: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); }
    </style>
</head>
<body>

    <!-- MENÚ LATERAL -->
    <div class="sidebar">
        <div class="sidebar-brand">Dolce Vida</div>
        <div class="sidebar-subtitle">Sistema de Inventario</div>
        <ul class="nav-menu">
            <li><a href="${pageContext.request.contextPath}/principal.jsp" class="nav-item-link active">🏠 Inicio</a></li>
            <li><a href="${pageContext.request.contextPath}/ProductoController" class="nav-item-link">📦 Inventario</a></li>
            <li><a href="${pageContext.request.contextPath}/categorias.jsp" class="nav-item-link">📁 Categorías</a></li>
            <li><a href="${pageContext.request.contextPath}/alertas.jsp" class="nav-item-link">⚠️ Alertas</a></li>
            <li><a href="${pageContext.request.contextPath}/facturacion.jsp" class="nav-item-link">🧾 Facturación</a></li>
            <li><a href="${pageContext.request.contextPath}/principal.jsp" class="nav-item-link">📊 Reportes</a></li>
            <li class="mt-5"><a href="${pageContext.request.contextPath}/index.html" class="nav-item-link" style="color: #ff8fa3;">🚪 Cerrar sesión</a></li>
        </ul>
    </div>

    <!-- CONTENIDO PRINCIPAL DE LA PÁGINA -->
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4" style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
            <div>
                <h2 class="fw-bold text-dark m-0" style="font-weight: bold; font-size: 1.8rem;">Panel principal</h2>
                <small class="text-muted">Bienvenido al sistema de Dolce Vida</small>
            </div>
            <div class="bg-white px-4 py-2 rounded-3 shadow-sm fw-semibold text-secondary" style="font-size: 0.9rem;">
                👤 Administrador
            </div>
        </div>

        <!-- TARJETAS DE INDICADORES SUPERIORES (KPIS) -->
        <div class="row g-4 mb-5" style="display: flex; gap: 20px; margin-bottom: 30px;">
            <div class="col" style="flex: 1;">
                <div class="stat-card">
                    <span style="font-size: 1.5rem; display: block; margin-bottom: 5px;">📦</span>
                    <small class="text-muted fw-semibold">Productos</small>
                    <h2 class="fw-bold my-1 text-dark">128</h2>
                    <small class="text-muted" style="font-size: 0.8rem;">Productos registrados</small>
                </div>
            </div>
            <div class="col" style="flex: 1;">
                <div class="stat-card">
                    <span style="font-size: 1.5rem; display: block; margin-bottom: 5px;">📁</span>
                    <small class="text-muted fw-semibold">Categorías</small>
                    <h2 class="fw-bold my-1 text-dark">8</h2>
                    <small class="text-muted" style="font-size: 0.8rem;">Categorías activas</small>
                </div>
            </div>
            <div class="col" style="flex: 1;">
                <div class="stat-card stat-card-warning">
                    <span style="font-size: 1.5rem; display: block; margin-bottom: 5px;">⚠️</span>
                    <small class="text-muted fw-semibold" style="color: #ffc107 !important;">Por vencer</small>
                    <h2 class="fw-bold my-1 text-dark">6</h2>
                    <small class="text-muted" style="font-size: 0.8rem;">Productos próximos a vencer</small>
                </div>
            </div>
            <div class="col" style="flex: 1;">
                <div class="stat-card">
                    <span style="font-size: 1.5rem; display: block; margin-bottom: 5px;">🧾</span>
                    <small class="text-muted fw-semibold">Ventas</small>
                    <h2 class="fw-bold my-1 text-dark">42</h2>
                    <small class="text-muted" style="font-size: 0.8rem;">Facturas registradas</small>
                </div>
            </div>
        </div>

        <!-- TABLA DE RESUMEN DEL INVENTARIO -->
        <div class="table-container">
            <h4 class="fw-bold text-dark mb-4" style="font-weight: bold; margin-bottom: 20px;">Resumen del inventario</h4>
            <table class="table table-hover align-middle" style="width: 100%;">
                <thead style="background-color: #f8f9fa; color: #6c757d;">
                    <tr>
                        <th style="padding: 12px;">Producto</th>
                        <th style="padding: 12px;">Categoría</th>
                        <th style="padding: 12px;">Cantidad</th>
                        <th style="padding: 12px;">Estado</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        Session hSession = HibernateUtil.getSessionFactory().openSession();
                        List<Producto> resumen = hSession.createQuery("FROM Producto", Producto.class).setMaxResults(3).list();
                        if (resumen != null && !resumen.isEmpty()) {
                            for (Producto p : resumen) {
                    %>
                    <tr style="border-bottom: 1px solid #eee;">
                        <td style="padding: 12px; font-weight: 500;"><%= p.getNombre() %></td>
                        <td style="padding: 12px; color: #6c757d;"><%= (p.getCategoria() != null) ? p.getCategoria().getNombreCategoria() : "Sin categoría" %></td>
                        <td style="padding: 12px;"><%= p.getCantidad() %></td>
                        <td style="padding: 12px;">
                            <span class="badge <%= (p.getCantidad() < 5) ? "bg-danger" : "bg-success" %>" style="padding: 6px 12px; border-radius: 20px; color: white;">
                                <%= (p.getCantidad() < 5) ? "Bajo stock" : "Disponible" %>
                            </span>
                        </td>
                    </tr>
                    <%
                            }
                        } else {
                    %>
                    <tr>
                        <td colspan="4" class="text-center text-muted py-4">No hay registros de inventario.</td>
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

