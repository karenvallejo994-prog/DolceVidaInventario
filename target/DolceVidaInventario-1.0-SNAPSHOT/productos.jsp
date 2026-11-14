<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.dolcevida.model.Producto"%>
<%@page import="com.dolcevida.model.Categoria"%>
<%
    // PROTECCIÓN DE SESIÓN (ACC-002)
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session.getAttribute("usuarioLogueado") == null) {
        response.sendRedirect("index.html");
        return;
    }
    String usuarioActual = (String) session.getAttribute("usuarioLogueado");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dolce Vida - Inventario de Productos</title>
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
        .table-container { background: white; border-radius: 15px; padding: 30px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); }
        .search-input { border-radius: 8px; border: 1px solid #dee2e6; padding: 8px 15px; width: 350px; }
        .btn-add-product { background-color: #7a3e52; color: white; border: none; border-radius: 8px; padding: 10px 20px; font-weight: 600; cursor: pointer; }
        .btn-add-product:hover { background-color: #5c2e3d; color: white; }
        .action-btn { background: #f8f9fa; border: 1px solid #dee2e6; border-radius: 6px; padding: 4px 8px; font-size: 0.9rem; cursor: pointer; text-decoration: none; display: inline-block; }
        .action-btn:hover { background: #e9ecef; }
        .modal-overlay { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 999; align-items: center; justify-content: center; }
        .modal-card { background: white; border-radius: 16px; width: 100%; max-width: 480px; padding: 30px; box-shadow: 0 15px 35px rgba(0,0,0,0.2); }
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
            <li class="mt-5"><a href="${pageContext.request.contextPath}/LogoutController" class="nav-item-link" style="color: #ff8fa3;">🚪 Cerrar sesión</a></li>
        </ul>
    </div>
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4" style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
            <div>
                <h2 class="fw-bold text-dark m-0" style="font-weight: bold; font-size: 1.8rem;">Inventario</h2>
                <small class="text-muted">Administración de productos registrados</small>
            </div>
            <div class="text-secondary" style="font-size: 0.9rem; font-weight: 600;">
                👤 <%= usuarioActual %>
            </div>
        </div>

        <div class="d-flex justify-content-between align-items-center mb-4" style="display: flex; justify-content: space-between; align-items: center; width: 100%; margin-bottom: 25px;">
            <input type="text" id="buscadorInventario" onkeyup="filtrarInventario()" class="search-input" placeholder="🔍 Buscar producto...">
            <button type="button" onclick="abrirModalNuevo()" class="btn-add-product">+ Nuevo producto</button>
        </div>

        <div class="table-container">
            <h5 class="fw-bold text-dark mb-1" style="font-weight: bold;">Productos registrados</h5>
            <small class="text-muted d-block mb-3" style="display: block; margin-bottom: 15px;">Inventario actual de Dolce Vida</small>
            
            <table class="table table-hover align-middle" style="width: 100%;" id="tablaProductos">
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
                        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                        Date hoy = new Date();
                        long quinceDiasMs = 15L * 24 * 60 * 60 * 1000;

                        if (productos != null && !productos.isEmpty()) {
                            for (Producto p : productos) {
                                String fechaTexto = (p.getFechaVencimiento() != null) ? sdf.format(p.getFechaVencimiento()) : "No aplica";
                                int idCat = (p.getCategoria() != null) ? p.getCategoria().getIdCategoria() : 1;

                                String textoEstado = "Disponible";
                                String colorBadge = "#198754";

                                if (p.getFechaVencimiento() != null) {
                                    long diferencia = p.getFechaVencimiento().getTime() - hoy.getTime();
                                    if (diferencia < 0) {
                                        textoEstado = "Vencido";
                                        colorBadge = "#dc3545";
                                    } else if (diferencia <= quinceDiasMs) {
                                        textoEstado = "Por vencer";
                                        colorBadge = "#fd7e14";
                                    }
                                }
                                if ("Disponible".equals(textoEstado) && p.getCantidad() < 5) {
                                    textoEstado = "Bajo stock";
                                    colorBadge = "#dc3545";
                                }
                    %>
                    <tr class="fila-producto" style="border-bottom: 1px solid #eee;">
                        <td style="padding: 12px; color: #6c757d;">DV00<%= p.getIdProducto() %></td>
                        <td style="padding: 12px; font-weight: bold; color: #333;"><%= p.getNombre() %></td>
                        <td style="padding: 12px; color: #6c757d;"><%= (p.getCategoria() != null) ? p.getCategoria().getNombreCategoria() : "Sin categoría" %></td>
                        <td style="padding: 12px;"><%= p.getCantidad() %></td>
                        <td style="padding: 12px; font-weight: 500;">$<%= String.format("%,.0f", p.getPrecio()) %></td>
                        <td style="padding: 12px; color: #6c757d;"><%= fechaTexto %></td>
                        <td style="padding: 12px;">
                            <span style="padding: 5px 12px; border-radius: 20px; color: white; font-size: 0.8rem; font-weight: 600; background-color: <%= colorBadge %>;">
                                <%= textoEstado %>
                            </span>
                        </td>
                        <td style="padding: 12px; text-align: center; white-space: nowrap;">
                            <button type="button" class="action-btn" title="Editar"
                                onclick="abrirModalEditar(<%= p.getIdProducto() %>, '<%= p.getNombre().replace("'", "\\'") %>', <%= idCat %>, <%= p.getCantidad() %>, <%= (int)p.getPrecio() %>, '<%= (p.getFechaVencimiento() != null) ? fechaTexto : "" %>')">✏️</button>
                            <a href="ProductoController?accion=eliminar&id=<%= p.getIdProducto() %>" 
                               onclick="return confirm('¿Estás segura de eliminar el producto <%= p.getNombre().replace("'", "\\'") %>?');" 
                               class="action-btn" title="Eliminar">🗑️</a>
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
    <!-- MODAL NUEVO PRODUCTO -->
    <div id="modalNuevo" class="modal-overlay">
        <div class="modal-card">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h4 style="margin: 0; font-weight: bold; color: #4a2834;">🍬 Nuevo Producto</h4>
                <button type="button" onclick="cerrarModales()" style="border: none; background: none; font-size: 1.3rem; cursor: pointer;">✕</button>
            </div>
            <form action="ProductoController" method="POST">
                <input type="hidden" name="accion" value="crear">
                
                <div class="mb-3">
                    <label class="form-label fw-semibold">Nombre del Producto</label>
                    <input type="text" name="nombre" class="form-control" placeholder="Ej: Chocolatina Jet x 12" required>
                </div>
                <div class="mb-3">
                    <label class="form-label fw-semibold">Categoría</label>
                    <select name="idCategoria" class="form-select" required>
                        <%
                            List<Categoria> cats = (List<Categoria>) request.getAttribute("categorias");
                            if (cats != null) {
                                for (Categoria c : cats) {
                        %>
                        <option value="<%= c.getIdCategoria() %>"><%= c.getNombreCategoria() %></option>
                        <%
                                }
                            }
                        %>
                    </select>
                </div>
                <div class="row g-2 mb-3" style="display: flex; gap: 10px;">
                    <div style="flex: 1;">
                        <label class="form-label fw-semibold">Cantidad Inicial</label>
                        <input type="number" name="cantidad" class="form-control" min="1" value="10" required>
                    </div>
                    <div style="flex: 1;">
                        <label class="form-label fw-semibold">Precio Venta ($)</label>
                        <input type="number" name="precio" class="form-control" min="100" step="50" placeholder="Ej: 3500" required>
                    </div>
                </div>
                <div class="mb-4">
                    <label class="form-label fw-semibold">Fecha de Vencimiento (Opcional)</label>
                    <input type="date" name="fechaVencimiento" class="form-control">
                </div>
                <div style="display: flex; gap: 10px;">
                    <button type="button" onclick="cerrarModales()" class="btn btn-light border w-100">Cancelar</button>
                    <button type="submit" class="btn-add-product w-100">Guardar Producto</button>
                </div>
            </form>
        </div>
    </div>

    <!-- MODAL EDITAR PRODUCTO -->
    <div id="modalEditar" class="modal-overlay">
        <div class="modal-card">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h4 style="margin: 0; font-weight: bold; color: #4a2834;">✏️ Editar Producto</h4>
                <button type="button" onclick="cerrarModales()" style="border: none; background: none; font-size: 1.3rem; cursor: pointer;">✕</button>
            </div>
            <form action="ProductoController" method="POST">
                <input type="hidden" name="accion" value="editar">
                <input type="hidden" name="idProducto" id="editId">
                
                <div class="mb-3">
                    <label class="form-label fw-semibold">Nombre del Producto</label>
                    <input type="text" name="nombre" id="editNombre" class="form-control" required>
                </div>
                <div class="mb-3">
                    <label class="form-label fw-semibold">Categoría</label>
                    <select name="idCategoria" id="editCategoria" class="form-select" required>
                        <%
                            if (cats != null) {
                                for (Categoria c : cats) {
                        %>
                        <option value="<%= c.getIdCategoria() %>"><%= c.getNombreCategoria() %></option>
                        <%
                                }
                            }
                        %>
                    </select>
                </div>
                <div class="row g-2 mb-3" style="display: flex; gap: 10px;">
                    <div style="flex: 1;">
                        <label class="form-label fw-semibold">Cantidad (Stock)</label>
                        <input type="number" name="cantidad" id="editCantidad" class="form-control" min="0" required>
                    </div>
                    <div style="flex: 1;">
                        <label class="form-label fw-semibold">Precio Venta ($)</label>
                        <input type="number" name="precio" id="editPrecio" class="form-control" min="100" required>
                    </div>
                </div>
                <div class="mb-4">
                    <label class="form-label fw-semibold">Fecha de Vencimiento</label>
                    <input type="date" name="fechaVencimiento" id="editFecha" class="form-control">
                </div>
                <div style="display: flex; gap: 10px;">
                    <button type="button" onclick="cerrarModales()" class="btn btn-light border w-100">Cancelar</button>
                    <button type="submit" class="btn-add-product w-100">Actualizar Cambios</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function abrirModalNuevo() {
            document.getElementById("modalNuevo").style.display = "flex";
        }

        function abrirModalEditar(id, nombre, idCat, cantidad, precio, fecha) {
            document.getElementById("editId").value = id;
            document.getElementById("editNombre").value = nombre;
            document.getElementById("editCategoria").value = idCat;
            document.getElementById("editCantidad").value = cantidad;
            document.getElementById("editPrecio").value = precio;
            document.getElementById("editFecha").value = fecha;
            document.getElementById("modalEditar").style.display = "flex";
        }

        function cerrarModales() {
            document.getElementById("modalNuevo").style.display = "none";
            document.getElementById("modalEditar").style.display = "none";
        }

        function filtrarInventario() {
            const texto = document.getElementById("buscadorInventario").value.toLowerCase();
            const filas = document.querySelectorAll(".fila-producto");
            filas.forEach(fila => {
                const contenido = fila.innerText.toLowerCase();
                fila.style.display = contenido.includes(texto) ? "" : "none";
            });
        }
    </script>

</body>
</html>
