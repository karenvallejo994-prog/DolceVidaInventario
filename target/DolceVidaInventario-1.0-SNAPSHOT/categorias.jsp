<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.dolcevida.model.Categoria"%>
<%@page import="com.dolcevida.model.Producto"%>
<%@page import="org.hibernate.Session"%>
<%@page import="com.dolcevida.util.HibernateUtil"%>
<%
    // PROTECCIÓN DE SESIÓN (ACC-002)
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
    <title>Dolce Vida - Categorías</title>
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
        .category-card { background: white; border-radius: 15px; border: 1px solid transparent; box-shadow: 0 4px 15px rgba(0,0,0,0.03); padding: 25px; transition: all 0.2s ease; height: 100%; display: flex; flex-direction: column; justify-content: space-between; }
        .category-card:hover { transform: translateY(-5px); box-shadow: 0 8px 25px rgba(74, 40, 52, 0.1); border-color: #ff6f91; }
        .btn-add { background-color: #7a3e52; color: white; border: none; border-radius: 8px; padding: 10px 20px; font-weight: 600; cursor: pointer; }
        .btn-add:hover { background-color: #5c2e3d; color: white; }
        .btn-view-products { background-color: #fdf2f5; color: #7a3e52; border: 1px solid #f5d0db; border-radius: 8px; padding: 6px 12px; font-size: 0.85rem; font-weight: 600; cursor: pointer; transition: all 0.2s; }
        .btn-view-products:hover { background-color: #7a3e52; color: white; }
        .icon-action { background: #f8f9fa; border: 1px solid #dee2e6; border-radius: 6px; padding: 4px 8px; font-size: 0.85rem; cursor: pointer; text-decoration: none; }
        .icon-action:hover { background: #e9ecef; }
        .modal-overlay { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 999; align-items: center; justify-content: center; }
        .modal-card { background: white; border-radius: 16px; width: 100%; max-width: 500px; padding: 30px; box-shadow: 0 15px 35px rgba(0,0,0,0.2); }
    </style>
</head>
<body>

    <!-- MENÚ LATERAL -->
    <div class="sidebar">
        <div class="sidebar-brand">Dolce Vida</div>
        <div class="sidebar-subtitle">Sistema de Inventario</div>
        <ul class="nav-menu">
            <li><a href="${pageContext.request.contextPath}/principal.jsp" class="nav-item-link">🏠 Inicio</a></li>
            <li><a href="${pageContext.request.contextPath}/ProductoController" class="nav-item-link">📦 Inventario</a></li>
            <li><a href="${pageContext.request.contextPath}/categorias.jsp" class="nav-item-link active">📁 Categorías</a></li>
            <li><a href="${pageContext.request.contextPath}/alertas.jsp" class="nav-item-link">⚠️ Alertas</a></li>
            <li><a href="${pageContext.request.contextPath}/facturacion.jsp" class="nav-item-link">🧾 Facturación</a></li>
            <li><a href="${pageContext.request.contextPath}/reportes.jsp" class="nav-item-link">📊 Reportes</a></li>
            <li class="mt-5"><a href="${pageContext.request.contextPath}/LogoutController" class="nav-item-link" style="color: #ff8fa3;">🚪 Cerrar sesión</a></li>
        </ul>
    </div>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4" style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
            <div>
                <h2 class="fw-bold text-dark m-0" style="font-weight: bold; font-size: 1.8rem;">Categorías</h2>
                <small class="text-muted">Clasificación interactiva de dulces y snacks</small>
            </div>
            <button type="button" onclick="abrirModalNuevaCat()" class="btn-add">+ Nueva categoría</button>
        </div>

        <div class="row g-4" style="display: flex; flex-wrap: wrap; gap: 20px;">
            <%
                Session hSession = HibernateUtil.getSessionFactory().openSession();
                List<Categoria> listaCategorias = hSession.createQuery("FROM Categoria", Categoria.class).list();
                List<Producto> todosProductos = hSession.createQuery("FROM Producto", Producto.class).list();

                if (listaCategorias != null && !listaCategorias.isEmpty()) {
                    for (Categoria cat : listaCategorias) {
                        int contadorProductos = 0;
                        StringBuilder listaHtmlProductos = new StringBuilder();

                        if (todosProductos != null) {
                            for (Producto p : todosProductos) {
                                if (p.getCategoria() != null && p.getCategoria().getIdCategoria() == cat.getIdCategoria()) {
                                    contadorProductos++;
                                    listaHtmlProductos.append("<li style='padding: 8px 0; border-bottom: 1px solid #eee; display: flex; justify-content: space-between;'>")
                                        .append("<span>🍬 <strong>").append(p.getNombre().replace("'", "&#39;")).append("</strong></span>")
                                        .append("<span class='text-muted'>Stock: ").append(p.getCantidad()).append(" | $").append(String.format("%,.0f", p.getPrecio())).append("</span>")
                                        .append("</li>");
                                }
                            }
                        }
                        String descSegura = (cat.getDescripcion() != null) ? cat.getDescripcion() : "Sin descripción asignada.";
            %>
            <div class="col-md-4" style="width: 31%; min-width: 290px;">
                <div class="card category-card">
                    <div>
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                            <h5 class="fw-bold text-dark m-0" style="font-weight: bold;"><%= cat.getNombreCategoria() %></h5>
                            <span style="font-size: 1.5rem;">📁</span>
                        </div>
                        <p class="text-muted small mb-3"><%= descSegura %></p>
                    </div>

                    <div>
                        <div style="background-color: #f8f9fa; padding: 8px 12px; border-radius: 8px; margin-bottom: 15px; font-size: 0.85rem; color: #4a2834; font-weight: 600;">
                            📦 <%= contadorProductos %> <%= (contadorProductos == 1) ? "producto asociado" : "productos asociados" %>
                        </div>

                        <div style="display: flex; justify-content: space-between; align-items: center; border-top: 1px solid #f1f1f1; padding-top: 12px;">
                            <button type="button" class="btn-view-products" 
                                onclick="verProductosCategoria('<%= cat.getNombreCategoria().replace("'", "\\'") %>', `<%= listaHtmlProductos.toString() %>`)">
                                Ver productos ➔
                            </button>
                            <div style="display: flex; gap: 6px;">
                                <button type="button" class="icon-action" title="Editar"
                                    onclick="abrirModalEditarCat(<%= cat.getIdCategoria() %>, '<%= cat.getNombreCategoria().replace("'", "\\'") %>', '<%= descSegura.replace("'", "\\'") %>')">✏️</button>
                                <a href="CategoriaController?accion=eliminar&id=<%= cat.getIdCategoria() %>" 
                                   onclick="return confirm('¿Eliminar la categoría <%= cat.getNombreCategoria().replace("'", "\\'") %>?');" 
                                   class="icon-action" title="Eliminar">🗑️</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <%
                    }
                } else {
            %>
            <div class="col-12 text-center text-muted py-5">No hay categorías registradas en el sistema.</div>
            <%
                }
                hSession.close();
            %>
        </div>
    </div>
    <!-- MODAL NUEVA CATEGORÍA -->
    <div id="modalNuevaCat" class="modal-overlay">
        <div class="modal-card">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h4 style="margin: 0; font-weight: bold; color: #4a2834;">📁 Nueva Categoría</h4>
                <button type="button" onclick="cerrarModalesCat()" style="border: none; background: none; font-size: 1.3rem; cursor: pointer;">✕</button>
            </div>
            <form action="CategoriaController" method="POST">
                <input type="hidden" name="accion" value="crear">
                <div class="mb-3">
                    <label class="form-label fw-semibold">Nombre de la Categoría</label>
                    <input type="text" name="nombreCategoria" class="form-control" placeholder="Ej: Gomitas y Ácidos" required>
                </div>
                <div class="mb-4">
                    <label class="form-label fw-semibold">Descripción</label>
                    <textarea name="descripcion" class="form-control" rows="3" placeholder="Describe qué tipo de dulces o snacks agrupa..." required></textarea>
                </div>
                <div style="display: flex; gap: 10px;">
                    <button type="button" onclick="cerrarModalesCat()" class="btn btn-light border w-100">Cancelar</button>
                    <button type="submit" class="btn-add w-100">Guardar Categoría</button>
                </div>
            </form>
        </div>
    </div>

    <!-- MODAL EDITAR CATEGORÍA -->
    <div id="modalEditarCat" class="modal-overlay">
        <div class="modal-card">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h4 style="margin: 0; font-weight: bold; color: #4a2834;">✏️ Editar Categoría</h4>
                <button type="button" onclick="cerrarModalesCat()" style="border: none; background: none; font-size: 1.3rem; cursor: pointer;">✕</button>
            </div>
            <form action="CategoriaController" method="POST">
                <input type="hidden" name="accion" value="editar">
                <input type="hidden" name="idCategoria" id="editCatId">
                <div class="mb-3">
                    <label class="form-label fw-semibold">Nombre de la Categoría</label>
                    <input type="text" name="nombreCategoria" id="editCatNombre" class="form-control" required>
                </div>
                <div class="mb-4">
                    <label class="form-label fw-semibold">Descripción</label>
                    <textarea name="descripcion" id="editCatDesc" class="form-control" rows="3" required></textarea>
                </div>
                <div style="display: flex; gap: 10px;">
                    <button type="button" onclick="cerrarModalesCat()" class="btn btn-light border w-100">Cancelar</button>
                    <button type="submit" class="btn-add w-100">Actualizar Categoría</button>
                </div>
            </form>
        </div>
    </div>

    <!-- MODAL VER PRODUCTOS DE LA CATEGORÍA -->
    <div id="modalVerProductos" class="modal-overlay">
        <div class="modal-card">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
                <h4 style="margin: 0; font-weight: bold; color: #4a2834;" id="tituloModalProductos">Productos</h4>
                <button type="button" onclick="cerrarModalesCat()" style="border: none; background: none; font-size: 1.3rem; cursor: pointer;">✕</button>
            </div>
            <ul id="listaProductosModal" style="list-style: none; padding: 0; max-height: 300px; overflow-y: auto; margin-bottom: 20px;">
            </ul>
            <div style="display: flex; gap: 10px;">
                <button type="button" onclick="cerrarModalesCat()" class="btn btn-light border w-100">Cerrar</button>
                <a href="${pageContext.request.contextPath}/ProductoController" class="btn-add w-100" style="text-align: center;">Ir al Inventario ➔</a>
            </div>
        </div>
    </div>

    <script>
        function abrirModalNuevaCat() {
            document.getElementById("modalNuevaCat").style.display = "flex";
        }

        function abrirModalEditarCat(id, nombre, desc) {
            document.getElementById("editCatId").value = id;
            document.getElementById("editCatNombre").value = nombre;
            document.getElementById("editCatDesc").value = desc;
            document.getElementById("modalEditarCat").style.display = "flex";
        }

        function verProductosCategoria(nombreCat, htmlLista) {
            document.getElementById("tituloModalProductos").innerText = "📁 " + nombreCat;
            const ul = document.getElementById("listaProductosModal");
            if (htmlLista && htmlLista.trim() !== "") {
                ul.innerHTML = htmlLista;
            } else {
                ul.innerHTML = "<li class='text-center text-muted py-4'>Aún no hay productos registrados en esta categoría.</li>";
            }
            document.getElementById("modalVerProductos").style.display = "flex";
        }

        function cerrarModalesCat() {
            document.getElementById("modalNuevaCat").style.display = "none";
            document.getElementById("modalEditarCat").style.display = "none";
            document.getElementById("modalVerProductos").style.display = "none";
        }
    </script>

</body>
</html>
