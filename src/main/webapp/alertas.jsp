<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.dolcevida.model.Producto"%>
<%@page import="org.hibernate.Session"%>
<%@page import="com.dolcevida.util.HibernateUtil"%>
<%
    // PROTECCIÓN DE SESIÓN (ACC-002): Bloquea acceso directo sin login y evita caché
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session.getAttribute("usuarioLogueado") == null) {
        response.sendRedirect("index.html");
        return;
    }
%>
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
        .alert-container { background: white; border-radius: 15px; padding: 30px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); margin-bottom: 30px; }
        .panel-warning-custom { border-left: 5px solid #dc3545 !important; background-color: #fff8f8; border-radius: 10px; padding: 15px; margin-bottom: 20px; }
        .panel-expiry-custom { border-left: 5px solid #fd7e14 !important; background-color: #fffaf3; border-radius: 10px; padding: 15px; margin-bottom: 20px; }
        .btn-surtir { background-color: #7a3e52; color: white; border: none; border-radius: 6px; padding: 6px 12px; font-size: 0.85rem; font-weight: 600; cursor: pointer; text-decoration: none; display: inline-block; }
        .btn-surtir:hover { background-color: #5c2e3d; color: white; }
        .modal-overlay { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 999; align-items: center; justify-content: center; }
        .modal-card { background: white; border-radius: 16px; width: 100%; max-width: 420px; padding: 30px; box-shadow: 0 15px 35px rgba(0,0,0,0.2); }
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
            <li class="mt-5"><a href="${pageContext.request.contextPath}/LogoutController" class="nav-item-link" style="color: #ff8fa3;">🚪 Cerrar sesión</a></li>
        </ul>
    </div>

    <%
        Session hSession = HibernateUtil.getSessionFactory().openSession();
        List<Producto> todosProductos = hSession.createQuery("FROM Producto", Producto.class).list();
        
        List<Producto> alertasStock = new ArrayList<>();
        List<Producto> alertasVencimiento = new ArrayList<>();
        
        Date hoy = new Date();
        long quinceDiasMs = 15L * 24 * 60 * 60 * 1000;
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

        if (todosProductos != null) {
            for (Producto p : todosProductos) {
                if (p.getCantidad() < 20) {
                    alertasStock.add(p);
                }
                if (p.getFechaVencimiento() != null) {
                    long diferencia = p.getFechaVencimiento().getTime() - hoy.getTime();
                    if (diferencia <= quinceDiasMs) {
                        alertasVencimiento.add(p);
                    }
                }
            }
        }
    %>

    <!-- CONTENIDO PRINCIPAL -->
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold text-dark m-0" style="font-weight: bold; font-size: 1.8rem;">Alertas del sistema</h2>
                <small class="text-muted">Detección automática de stock crítico y fechas de vencimiento</small>
            </div>
        </div>

        <!-- PANEL 1: STOCK CRÍTICO -->
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
                        <th style="padding: 12px; text-align: center;">Acción Rápida</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        if (!alertasStock.isEmpty()) {
                            for (Producto p : alertasStock) {
                                int idCat = (p.getCategoria() != null) ? p.getCategoria().getIdCategoria() : 1;
                                String fechaStr = (p.getFechaVencimiento() != null) ? sdf.format(p.getFechaVencimiento()) : "";
                    %>
                    <tr style="border-bottom: 1px solid #eee;">
                        <td style="padding: 12px; color: #6c757d;">DV00<%= p.getIdProducto() %></td>
                        <td style="padding: 12px; font-weight: bold; color: #333;"><%= p.getNombre() %></td>
                        <td style="padding: 12px; color: #6c757d;">20 unidades</td>
                        <td style="padding: 12px; font-weight: bold; color: #dc3545;"><%= p.getCantidad() %> unidades</td>
                        <td style="padding: 12px;">
                            <span style="padding: 5px 12px; border-radius: 20px; color: white; font-size: 0.8rem; font-weight: bold; background-color: #dc3545;">
                                Crítico 🛑
                            </span>
                        </td>
                        <td style="padding: 12px; text-align: center;">
                            <button type="button" class="btn-surtir"
                                onclick="abrirModalSurtir(<%= p.getIdProducto() %>, '<%= p.getNombre().replace("'", "\\'") %>', <%= idCat %>, <%= p.getCantidad() %>, <%= (int)p.getPrecio() %>, '<%= fechaStr %>')">
                                + Reabastecer
                            </button>
                        </td>
                    </tr>
                    <%
                            }
                        } else {
                    %>
                    <tr>
                        <td colspan="6" class="text-center text-muted py-4">✅ Todo el inventario se encuentra correctamente abastecido.</td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
        </div>
        <!-- PANEL 2: CONTROL DE VENCIMIENTOS -->
        <div class="alert-container">
            <div class="panel-expiry-custom">
                <h5 class="fw-bold m-0" style="color: #d9530f;">⏳ Control de Fechas de Vencimiento</h5>
                <small class="text-muted">Productos vencidos o próximos a vencer dentro de los siguientes 15 días.</small>
            </div>

            <table class="table table-hover align-middle" style="width: 100%;">
                <thead style="background-color: #f8f9fa; color: #6c757d; font-weight: 600;">
                    <tr>
                        <th style="padding: 12px;">Código</th>
                        <th style="padding: 12px;">Producto</th>
                        <th style="padding: 12px;">Stock Actual</th>
                        <th style="padding: 12px;">Fecha de Vencimiento</th>
                        <th style="padding: 12px;">Estado</th>
                        <th style="padding: 12px; text-align: center;">Acción</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        if (!alertasVencimiento.isEmpty()) {
                            for (Producto p : alertasVencimiento) {
                                boolean estaVencido = p.getFechaVencimiento().getTime() < hoy.getTime();
                    %>
                    <tr style="border-bottom: 1px solid #eee;">
                        <td style="padding: 12px; color: #6c757d;">DV00<%= p.getIdProducto() %></td>
                        <td style="padding: 12px; font-weight: bold; color: #333;"><%= p.getNombre() %></td>
                        <td style="padding: 12px;"><%= p.getCantidad() %> unidades</td>
                        <td style="padding: 12px; font-weight: 600; color: <%= estaVencido ? "#dc3545" : "#d9530f" %>;">
                            <%= sdf.format(p.getFechaVencimiento()) %>
                        </td>
                        <td style="padding: 12px;">
                            <span style="padding: 5px 12px; border-radius: 20px; color: white; font-size: 0.8rem; font-weight: bold; background-color: <%= estaVencido ? "#dc3545" : "#fd7e14" %>;">
                                <%= estaVencido ? "Vencido ⛔" : "Por vencer ⚠️" %>
                            </span>
                        </td>
                        <td style="padding: 12px; text-align: center;">
                            <a href="${pageContext.request.contextPath}/ProductoController" class="btn-surtir" style="background-color: #6c757d;">Gestionar en Inventario</a>
                        </td>
                    </tr>
                    <%
                            }
                        } else {
                    %>
                    <tr>
                        <td colspan="6" class="text-center text-muted py-4">✅ Ningún producto está vencido ni próximo a vencer en los próximos 15 días.</td>
                    </tr>
                    <%
                        }
                        hSession.close();
                    %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- MODAL REABASTECER RÁPIDO -->
    <div id="modalSurtir" class="modal-overlay">
        <div class="modal-card">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
                <h5 style="margin: 0; font-weight: bold; color: #4a2834;">📦 Reabastecer Producto</h5>
                <button type="button" onclick="cerrarModalSurtir()" style="border: none; background: none; font-size: 1.2rem; cursor: pointer;">✕</button>
            </div>
            <p class="text-muted small mb-3" id="surtirTitulo">Producto</p>
            <form action="ProductoController" method="POST">
                <input type="hidden" name="accion" value="editar">
                <input type="hidden" name="idProducto" id="surtirId">
                <input type="hidden" name="nombre" id="surtirNombre">
                <input type="hidden" name="idCategoria" id="surtirCategoria">
                <input type="hidden" name="precio" id="surtirPrecio">
                <input type="hidden" name="fechaVencimiento" id="surtirFecha">

                <div class="mb-4">
                    <label class="form-label fw-semibold">Nuevo Stock Total en Bodega</label>
                    <input type="number" name="cantidad" id="surtirCantidad" class="form-control" min="1" required>
                    <small class="text-muted">Escribe la cantidad total que queda después de recibir el pedido.</small>
                </div>
                <div style="display: flex; gap: 10px;">
                    <button type="button" onclick="cerrarModalSurtir()" class="btn btn-light border w-100">Cancelar</button>
                    <button type="submit" class="btn-surtir w-100" style="padding: 10px;">Actualizar Stock</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function abrirModalSurtir(id, nombre, idCat, cantActual, precio, fecha) {
            document.getElementById("surtirTitulo").innerText = "Producto: " + nombre + " (Actual: " + cantActual + " und.)";
            document.getElementById("surtirId").value = id;
            document.getElementById("surtirNombre").value = nombre;
            document.getElementById("surtirCategoria").value = idCat;
            document.getElementById("surtirCantidad").value = cantActual + 20;
            document.getElementById("surtirPrecio").value = precio;
            document.getElementById("surtirFecha").value = fecha;
            document.getElementById("modalSurtir").style.display = "flex";
        }

        function cerrarModalSurtir() {
            document.getElementById("modalSurtir").style.display = "none";
        }
    </script>

</body>
</html>
