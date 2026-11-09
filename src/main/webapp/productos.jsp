<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.dolcevida.model.Producto"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dolce Vida - Inventario de Productos</title>
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
        .table-container { background: white; border-radius: 15px; padding: 30px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); }
        .search-input { border-radius: 8px; border: 1px solid #dee2e6; padding: 8px 15px; width: 350px; }
        .btn-add-product { background-color: #7a3e52; color: white; border: none; border-radius: 8px; padding: 10px 20px; font-weight: 600; }
        .btn-add-product:hover { background-color: #5c2e3d; color: white; }
        .action-btn { background: #f8f9fa; border: 1px solid #dee2e6; border-radius: 6px; padding: 4px 8px; font-size: 0.9rem; cursor: pointer; text-decoration: none; }
        .action-btn-edit { color: #fd7e14; }
        .action-btn-delete { color: #dc3545; }
    </style>
</head>
<body>

    <!-- MENÚ LATERAL -->
    <div class="sidebar">
        <div class="sidebar-brand">Dolce Vida</div>
        <div class="sidebar-subtitle">Sistema de Inventario</div>
        <ul class="nav-menu">
            <li><a href="${pageContext.request.contextPath}/principal.jsp" class="nav-item-link">🏠 Inicio</a></li>
            <li><a href="${pageContext.request.contextPath}/ProductoController" class="nav-item-link active">📦 Inventario</a></li>
            <li><a href="${pageContext.request.contextPath}/categorias.jsp" class="nav-item-link">📁 Categorías</a></li>
            <li><a href="${pageContext.request.contextPath}/alertas.jsp" class="nav-item-link">⚠️ Alertas</a></li>
            <li><a href="${pageContext.request.contextPath}/facturacion.jsp" class="nav-item-link">🧾 Facturación</a></li>
            <li><a href="${pageContext.request.contextPath}/principal.jsp" class="nav-item-link">📊 Reportes</a></li>
            <li class="mt-5"><a href="${pageContext.request.contextPath}/index.html" class="nav-item-link" style="color: #ff8fa3;">🚪 Cerrar sesión</a></li>
        </ul>
    </div>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4" style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
            <div>
                <h2 class="fw-bold text-dark m-0" style="font-weight: bold; font-size: 1.8rem;">Inventario</h2>
                <small class="text-muted">Administración de productos registrados</small>
            </div>
            <div class="text-secondary" style="font-size: 0.9rem; font-weight: 600;">
                👤 Administrador
            </div>
        </div>

        <div class="d-flex justify-content-between align-items-center mb-4" style="display: flex; justify-content: space-between; align-items: center; width: 100%; margin-bottom: 25px;">
            <input type="text" class="search-input" placeholder="🔍 Buscar producto...">
            <a href="${pageContext.request.contextPath}/movimientos.jsp" class="btn btn-add-product">+ Nuevo producto</a>
        </div>

        <div class="table-container">
            <h5 class="fw-bold text-dark mb-1" style="font-weight: bold;">Productos registrados</h5>
            <small class="text-muted d-block mb-3" style="display: block; margin-bottom: 15px;">Inventario actual de Dolce Vida</small>
            
            <table class="table table-hover align-middle" style="width: 100%;">
                <thead style="background-color: #f8f9fa; color: #6c757d; font-weight: 600;">
                    <tr>
                        <th style="padding: 12px;">Código</th>
                        <th style="padding: 12px;">Producto</th>
                        <th style="padding: 12px;">Categoría</th>
                        <th style="padding: 12px;">Cantidad</th>
                        <th style="padding: 12px;">Precio</th>
                        <th style="padding: 12px;">Vencimiento</th>
                        <th style="padding: 12px;">Estado</th>
                        <th style="padding: 12px; text-align: center;">Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        List<Producto> productos = (List<Producto>) request.getAttribute("productos");
                        if (productos != null && !productos.isEmpty()) {
                            for (Producto p : productos) {
                    %>
                    <tr style="border-bottom: 1px solid #eee;">
                        <td style="padding: 12px; color: #6c757d;">DV00<%= p.getIdProducto() %></td>
                        <td style="padding: 12px; font-weight: bold; color: #333;"><%= p.getNombre() %></td>
                        <td style="padding: 12px; color: #6c757d;"><%= (p.getCategoria() != null) ? p.getCategoria().getNombreCategoria() : "Sin categoría" %></td>
                        <td style="padding: 12px;"><%= p.getCantidad() %></td>
                        <td style="padding: 12px; font-weight: 500;">$<%= String.format("%,.0f", p.getPrecio()) %></td>
                        <td style="padding: 12px; color: #6c757d;"><%= (p.getFechaVencimiento() != null) ? p.getFechaVencimiento() : "No aplica" %></td>
                        <td style="padding: 12px;">
                            <span class="badge <%= (p.getCantidad() < 5) ? "bg-danger" : "bg-success" %>" style="padding: 6px 12px; border-radius: 20px; color: white;">
                                <%= (p.getCantidad() < 5) ? "Bajo stock" : "Disponible" %>
                            </span>
                        </td>
                        <td style="padding: 12px; text-align: center;">
                            <a href="#" class="action-btn action-btn-edit" title="Editar">✏️</a>
                            <a href="#" class="action-btn action-btn-delete" title="Eliminar">🗑️</a>
                        </td>
                    </tr>
                    <%
                            }
                        } else {
                    %>
                    <tr>
                        <td colspan="8" class="text-center text-muted py-4">No hay productos registrados en el inventario actual.</td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>

</body>
</html>

