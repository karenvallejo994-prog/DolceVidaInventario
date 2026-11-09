<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.dolcevida.model.Categoria"%>
<%@page import="org.hibernate.Session"%>
<%@page import="com.dolcevida.util.HibernateUtil"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dolce Vida - Categorías</title>
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
        .category-card { background: white; border-radius: 15px; border: none; box-shadow: 0 4px 15px rgba(0,0,0,0.02); padding: 25px; transition: transform 0.2s; }
        .category-card:hover { transform: translateY(-5px); box-shadow: 0 8px 20px rgba(0,0,0,0.08); }
        .btn-add { background-color: #7a3e52; color: white; border: none; border-radius: 8px; padding: 10px 20px; font-weight: 600; text-decoration: none; }
        .btn-add:hover { background-color: #5c2e3d; color: white; }
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
            <li><a href="${pageContext.request.contextPath}/principal.jsp" class="nav-item-link">📊 Reportes</a></li>
            <li class="mt-5"><a href="${pageContext.request.contextPath}/index.html" class="nav-item-link" style="color: #ff8fa3;">🚪 Cerrar sesión</a></li>
        </ul>
    </div>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4" style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
            <div>
                <h2 class="fw-bold text-dark m-0" style="font-weight: bold; font-size: 1.8rem;">Categorías</h2>
                <small class="text-muted">Clasificación de dulces y snacks</small>
            </div>
            <a href="#" class="btn-add">+ Nueva categoría</a>
        </div>

        <div class="row g-4" style="display: flex; flex-wrap: wrap; gap: 20px;">
            <%
                Session hSession = HibernateUtil.getSessionFactory().openSession();
                List<Categoria> listaCategorias = hSession.createQuery("FROM Categoria", Categoria.class).list();
                if (listaCategorias != null && !listaCategorias.isEmpty()) {
                    for (Categoria cat : listaCategorias) {
            %>
            <div class="col-md-4" style="width: 31%; min-width: 280px;">
                <div class="card category-card">
                    <div class="d-flex align-items-center justify-content-between mb-3" style="display: flex; justify-content: space-between; align-items: center;">
                        <h5 class="fw-bold text-dark m-0" style="font-weight: bold;"><%= cat.getNombreCategoria() %></h5>
                        <span class="fs-4">📁</span>
                    </div>
                    <p class="text-muted small mb-0"><%= (cat.getDescripcion() != null) ? cat.getDescripcion() : "Sin descripción asignada." %></p>
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

</body>
</html>
