<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="com.mycompany.hotelmanagementsystem.service.AdminFeedbackService" %>
<%@ page import="com.mycompany.hotelmanagementsystem.service.RoomService" %>
<%@ page import="com.mycompany.hotelmanagementsystem.entity.Feedback" %>
<%@ page import="com.mycompany.hotelmanagementsystem.entity.RoomType" %>
<%@ page import="java.util.List" %>
<%
    // Load visible customer reviews for testimonials section
    if (request.getAttribute("reviews") == null) {
        try {
            AdminFeedbackService fbService = new AdminFeedbackService();
            List<Feedback> reviews = fbService.getVisibleFeedback(6);
            request.setAttribute("reviews", reviews);
        } catch (Exception e) {
            request.setAttribute("reviews", java.util.List.of());
        }
    }
    // Load room types for rooms section
    if (request.getAttribute("roomTypes") == null) {
        try {
            RoomService roomService = new RoomService();
            List<RoomType> roomTypes = roomService.getAllRoomTypes();
            request.setAttribute("roomTypes", roomTypes);
        } catch (Exception e) {
            request.setAttribute("roomTypes", java.util.List.of());
        }
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="Luxury Hotel - Trải nghiệm nghỉ dưỡng đẳng cấp 5 sao">
    <title>Luxury Hotel - Khách sạn sang trọng hàng đầu</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main-styles.css" rel="stylesheet">
</head>
<body style="font-family: 'Lato', sans-serif;">

    <!-- ============================================
         Navigation - Fixed
         ============================================ -->
    <nav class="navbar navbar-expand-lg navbar-landing" id="mainNav">
        <div class="container">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/">
                Luxury<span>Hotel</span>
            </a>
            <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="#features">Dịch vụ</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#rooms">Phòng</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#amenities">Tiện nghi</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#testimonials">Đánh giá</a>
                    </li>
                </ul>
                <ul class="navbar-nav">
                    <c:choose>
                        <c:when test="${not empty sessionScope.loggedInAccount}">
                            <li class="nav-item dropdown">
                                <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
                                    <i class="bi bi-person-circle me-1"></i>
                                    ${sessionScope.loggedInAccount.fullName}
                                </a>
                                <ul class="dropdown-menu dropdown-menu-end">
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/customer/profile">Hồ sơ</a></li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/customer/bookings">Đặt phòng của tôi</a></li>
                                    <li><hr class="dropdown-divider"></li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/auth/logout">Đăng xuất</a></li>
                                </ul>
                            </li>
                        </c:when>
                        <c:otherwise>
                            <li class="nav-item">
                                <a class="nav-link" href="${pageContext.request.contextPath}/auth/login">Đăng nhập</a>
                            </li>
                            <li class="nav-item ms-2">
                                <a class="btn btn-sm px-3 py-2" href="${pageContext.request.contextPath}/auth/register"
                                   style="background: linear-gradient(135deg, #c9a227 0%, #a68419 100%); color: #fff; border-radius: 20px; font-weight: 500;">
                                    Đăng ký
                                </a>
                            </li>
                        </c:otherwise>
                    </c:choose>
                </ul>
            </div>
        </div>
    </nav>

    <!-- ============================================
         Hero Section
         Image: 1920x1080px - /assets/images/home/hero-bg.jpg
         ============================================ -->
    <section class="hero-section" id="hero">
        <img src="https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1920&q=80" alt="Luxury Hotel" class="hero-bg">
        <div class="hero-overlay"></div>
        <div class="hero-content">
            <h1 class="animate-fade-in-up">
                Trải nghiệm nghỉ dưỡng<br><span>đẳng cấp 5 sao</span>
            </h1>
            <p class="animate-fade-in-up animate-delay-2">
                Khám phá không gian sang trọng, dịch vụ hoàn hảo và những khoảnh khắc đáng nhớ tại Luxury Hotel
            </p>
            <div class="hero-buttons animate-fade-in-up animate-delay-3">
                <a href="${pageContext.request.contextPath}/rooms" class="btn btn-hero-primary">
                    <i class="bi bi-calendar-check me-2"></i>Đặt phòng ngay
                </a>
                <a href="#rooms" class="btn btn-hero-outline">
                    <i class="bi bi-eye me-2"></i>Xem phòng
                </a>
            </div>
        </div>
        <a href="#features" class="hero-scroll-indicator">
            <i class="bi bi-chevron-down"></i>
        </a>
    </section>

    <!-- ============================================
         Features Section
         ============================================ -->
    <section class="section section-light" id="features">
        <div class="container">
            <div class="scroll-reveal">
                <h2 class="section-title">Tại sao chọn chúng tôi?</h2>
                <p class="section-subtitle">Chúng tôi cam kết mang đến trải nghiệm nghỉ dưỡng tuyệt vời nhất cho quý khách</p>
            </div>

            <div class="row g-4">
                <div class="col-md-6 col-lg-3 scroll-reveal scroll-delay-1">
                    <div class="feature-card">
                        <div class="feature-icon">
                            <i class="bi bi-geo-alt"></i>
                        </div>
                        <h3>Vị trí đắc địa</h3>
                        <p>Tọa lạc tại trung tâm thành phố, thuận tiện di chuyển đến mọi địa điểm</p>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3 scroll-reveal scroll-delay-2">
                    <div class="feature-card">
                        <div class="feature-icon">
                            <i class="bi bi-shield-check"></i>
                        </div>
                        <h3>An toàn tuyệt đối</h3>
                        <p>Hệ thống an ninh 24/7, đảm bảo sự an toàn cho quý khách</p>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3 scroll-reveal scroll-delay-3">
                    <div class="feature-card">
                        <div class="feature-icon">
                            <i class="bi bi-star"></i>
                        </div>
                        <h3>Dịch vụ 5 sao</h3>
                        <p>Đội ngũ nhân viên chuyên nghiệp, tận tâm phục vụ quý khách</p>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3 scroll-reveal scroll-delay-4">
                    <div class="feature-card">
                        <div class="feature-icon">
                            <i class="bi bi-currency-dollar"></i>
                        </div>
                        <h3>Giá cả hợp lý</h3>
                        <p>Mức giá cạnh tranh với nhiều ưu đãi hấp dẫn cho khách hàng</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- ============================================
         Rooms Section
         Images: 400x300px - /assets/images/home/room-*.jpg
         ============================================ -->
    <section class="section" id="rooms" style="background: #fff;">
        <div class="container">
            <div class="scroll-reveal">
                <h2 class="section-title">Phòng nghỉ của chúng tôi</h2>
                <p class="section-subtitle">Đa dạng loại phòng phù hợp với mọi nhu cầu của quý khách</p>
            </div>

            <%-- Fallback images per card index --%>
            <c:set var="fallbackImg0" value="https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80" />
            <c:set var="fallbackImg1" value="https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80" />
            <c:set var="fallbackImg2" value="https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&q=80" />

            <div class="row g-4">
                <c:forEach var="rt" items="${roomTypes}" varStatus="loop">
                    <c:if test="${loop.index < 3}">
                        <div class="col-md-6 col-lg-4 scroll-reveal scroll-delay-${loop.index + 1}">
                            <div class="room-card">
                                <div class="room-card-image">
                                    <c:choose>
                                        <c:when test="${not empty rt.images and not empty rt.images[0].imageUrl}">
                                            <%-- DB image: check if absolute URL or relative path --%>
                                            <c:choose>
                                                <c:when test="${rt.images[0].imageUrl.startsWith('http')}">
                                                    <img src="${rt.images[0].imageUrl}" alt="${rt.typeName}">
                                                </c:when>
                                                <c:otherwise>
                                                    <img src="${pageContext.request.contextPath}${rt.images[0].imageUrl}" alt="${rt.typeName}">
                                                </c:otherwise>
                                            </c:choose>
                                        </c:when>
                                        <c:otherwise>
                                            <%-- Fallback: different Unsplash image per card --%>
                                            <c:choose>
                                                <c:when test="${loop.index == 0}"><img src="${fallbackImg0}" alt="${rt.typeName}"></c:when>
                                                <c:when test="${loop.index == 1}"><img src="${fallbackImg1}" alt="${rt.typeName}"></c:when>
                                                <c:otherwise><img src="${fallbackImg2}" alt="${rt.typeName}"></c:otherwise>
                                            </c:choose>
                                        </c:otherwise>
                                    </c:choose>
                                    <c:if test="${loop.index == 0}">
                                        <span class="room-card-badge">Phổ biến</span>
                                    </c:if>
                                    <c:if test="${loop.index == 1}">
                                        <span class="room-card-badge" style="background: #c9a227;">Hot</span>
                                    </c:if>
                                    <c:if test="${loop.index == 2}">
                                        <span class="room-card-badge" style="background: #1a1a2e;">VIP</span>
                                    </c:if>
                                </div>
                                <div class="room-card-body">
                                    <h3>${rt.typeName}</h3>
                                    <p>
                                        <c:choose>
                                            <c:when test="${not empty rt.description}">
                                                ${rt.description}
                                            </c:when>
                                            <c:otherwise>
                                                Phòng ${rt.typeName} với đầy đủ tiện nghi, phù hợp cho ${rt.capacity} người
                                            </c:otherwise>
                                        </c:choose>
                                    </p>
                                    <div class="room-card-price">
                                        <span class="price"><fmt:formatNumber value="${rt.basePrice}" type="number" groupingUsed="true"/>đ</span>
                                        <span class="period">/đêm</span>
                                    </div>
                                    <div class="room-card-features">
                                        <span><i class="bi bi-people"></i> ${rt.capacity} người</span>
                                        <span><i class="bi bi-wifi"></i> WiFi</span>
                                    </div>
                                    <a href="${pageContext.request.contextPath}/rooms/detail?typeId=${rt.typeId}" class="btn btn-room">Xem chi tiết</a>
                                </div>
                            </div>
                        </div>
                    </c:if>
                </c:forEach>
            </div>

            <div class="text-center mt-5">
                <a href="${pageContext.request.contextPath}/rooms" class="btn btn-hero-primary">
                    Xem tất cả phòng <i class="bi bi-arrow-right ms-2"></i>
                </a>
            </div>
        </div>
    </section>

    <!-- ============================================
         Amenities Section
         ============================================ -->
    <section class="section section-dark" id="amenities">
        <div class="container">
            <div class="scroll-reveal">
                <h2 class="section-title">Tiện nghi & Dịch vụ</h2>
                <p class="section-subtitle">Tận hưởng các tiện nghi đẳng cấp trong suốt kỳ nghỉ của bạn</p>
            </div>

            <div class="row g-4 scroll-reveal">
                <div class="col-md-6 col-lg-4">
                    <div class="amenity-item">
                        <div class="amenity-icon"><i class="bi bi-wifi"></i></div>
                        <div>
                            <h4>WiFi miễn phí</h4>
                            <p>Kết nối internet tốc độ cao toàn khách sạn</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 col-lg-4">
                    <div class="amenity-item">
                        <div class="amenity-icon"><i class="bi bi-water"></i></div>
                        <div>
                            <h4>Hồ bơi</h4>
                            <p>Hồ bơi ngoài trời với view panorama tuyệt đẹp</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 col-lg-4">
                    <div class="amenity-item">
                        <div class="amenity-icon"><i class="bi bi-heart-pulse"></i></div>
                        <div>
                            <h4>Spa & Wellness</h4>
                            <p>Dịch vụ spa chuyên nghiệp, thư giãn toàn thân</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 col-lg-4">
                    <div class="amenity-item">
                        <div class="amenity-icon"><i class="bi bi-cup-hot"></i></div>
                        <div>
                            <h4>Nhà hàng</h4>
                            <p>Ẩm thực đa dạng từ Á đến Âu</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 col-lg-4">
                    <div class="amenity-item">
                        <div class="amenity-icon"><i class="bi bi-bicycle"></i></div>
                        <div>
                            <h4>Phòng Gym</h4>
                            <p>Trang thiết bị hiện đại, mở cửa 24/7</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 col-lg-4">
                    <div class="amenity-item">
                        <div class="amenity-icon"><i class="bi bi-car-front"></i></div>
                        <div>
                            <h4>Đưa đón sân bay</h4>
                            <p>Dịch vụ đưa đón tận nơi, xe sang trọng</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- ============================================
         Testimonials Section - Dynamic Reviews Carousel
         ============================================ -->
    <section class="section section-light" id="testimonials">
        <div class="container">
            <div class="scroll-reveal">
                <h2 class="section-title">Khách hàng nói gì về chúng tôi</h2>
                <p class="section-subtitle">Hàng nghìn khách hàng đã tin tưởng và hài lòng với dịch vụ của chúng tôi</p>
            </div>

            <c:choose>
                <c:when test="${not empty reviews}">
                    <!-- Reviews Carousel -->
                    <div class="testimonial-carousel scroll-reveal">
                        <div class="testimonial-track" id="testimonialTrack">
                            <c:forEach var="review" items="${reviews}">
                                <div class="testimonial-slide">
                                    <div class="testimonial-card-v2">
                                        <div class="testimonial-quote-icon">
                                            <i class="bi bi-quote"></i>
                                        </div>
                                        <div class="testimonial-rating">
                                            <c:forEach begin="1" end="5" var="star">
                                                <c:choose>
                                                    <c:when test="${star <= review.rating}">
                                                        <i class="bi bi-star-fill"></i>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <i class="bi bi-star"></i>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:forEach>
                                        </div>
                                        <p class="testimonial-text">"${review.comment}"</p>
                                        <div class="testimonial-footer">
                                            <img src="https://ui-avatars.com/api/?name=${review.booking.customer.account.fullName}&background=c9a227&color=fff&size=80&rounded=true&bold=true"
                                                 alt="${review.booking.customer.account.fullName}" class="testimonial-avatar-img">
                                            <div class="testimonial-info">
                                                <h5>${review.booking.customer.account.fullName}</h5>
                                                <span>Phòng ${review.booking.room.roomNumber} - ${review.booking.room.roomType.typeName}</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>

                        <!-- Carousel Controls -->
                        <button class="carousel-btn carousel-btn-prev" id="prevBtn" aria-label="Previous">
                            <i class="bi bi-chevron-left"></i>
                        </button>
                        <button class="carousel-btn carousel-btn-next" id="nextBtn" aria-label="Next">
                            <i class="bi bi-chevron-right"></i>
                        </button>

                        <!-- Carousel Dots -->
                        <div class="carousel-dots" id="carouselDots"></div>
                    </div>
                </c:when>
                <c:otherwise>
                    <!-- Fallback static testimonials -->
                    <div class="row g-4 scroll-reveal">
                        <div class="col-md-6 col-lg-4">
                            <div class="testimonial-card-v2">
                                <div class="testimonial-quote-icon"><i class="bi bi-quote"></i></div>
                                <div class="testimonial-rating">
                                    <i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i>
                                </div>
                                <p class="testimonial-text">"Dịch vụ tuyệt vời, nhân viên thân thiện. Phòng sạch sẽ và view rất đẹp. Chắc chắn sẽ quay lại!"</p>
                                <div class="testimonial-footer">
                                    <img src="https://ui-avatars.com/api/?name=Nguyen+Thao&background=c9a227&color=fff&size=80&rounded=true&bold=true" alt="Nguyen Thao" class="testimonial-avatar-img">
                                    <div class="testimonial-info"><h5>Nguyễn Thảo</h5><span>Hà Nội</span></div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6 col-lg-4">
                            <div class="testimonial-card-v2">
                                <div class="testimonial-quote-icon"><i class="bi bi-quote"></i></div>
                                <div class="testimonial-rating">
                                    <i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i>
                                </div>
                                <p class="testimonial-text">"Kỳ nghỉ gia đình tuyệt vời. Bể bơi rộng, buffet sáng đa dạng. Con tôi rất thích!"</p>
                                <div class="testimonial-footer">
                                    <img src="https://ui-avatars.com/api/?name=Tran+Minh&background=1a1a2e&color=fff&size=80&rounded=true&bold=true" alt="Tran Minh" class="testimonial-avatar-img">
                                    <div class="testimonial-info"><h5>Trần Minh</h5><span>TP. Hồ Chí Minh</span></div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6 col-lg-4">
                            <div class="testimonial-card-v2">
                                <div class="testimonial-quote-icon"><i class="bi bi-quote"></i></div>
                                <div class="testimonial-rating">
                                    <i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-star-half"></i>
                                </div>
                                <p class="testimonial-text">"Vị trí trung tâm, đi lại thuận tiện. Giá cả hợp lý so với chất lượng dịch vụ."</p>
                                <div class="testimonial-footer">
                                    <img src="https://ui-avatars.com/api/?name=Le+Huong&background=16213e&color=fff&size=80&rounded=true&bold=true" alt="Le Huong" class="testimonial-avatar-img">
                                    <div class="testimonial-info"><h5>Lê Hương</h5><span>Đà Nẵng</span></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </section>

    <!-- ============================================
         CTA Section
         ============================================ -->
    <section class="cta-section">
        <div class="container">
            <h2>Sẵn sàng cho kỳ nghỉ của bạn?</h2>
            <p>Đặt phòng ngay hôm nay để nhận ưu đãi đặc biệt lên đến 20%</p>
            <a href="${pageContext.request.contextPath}/rooms" class="btn btn-cta">
                <i class="bi bi-calendar-check me-2"></i>Đặt phòng ngay
            </a>
        </div>
    </section>

    <!-- ============================================
         Footer
         ============================================ -->
    <footer class="footer">
        <div class="container">
            <div class="row g-4">
                <div class="col-lg-4">
                    <div class="footer-brand">Luxury<span>Hotel</span></div>
                    <p class="footer-text">
                        Luxury Hotel - Điểm đến lý tưởng cho kỳ nghỉ của bạn.
                        Với dịch vụ đẳng cấp 5 sao, chúng tôi cam kết mang đến trải nghiệm nghỉ dưỡng tuyệt vời nhất.
                    </p>
                    <div class="footer-social">
                        <a href="#"><i class="bi bi-facebook"></i></a>
                        <a href="#"><i class="bi bi-instagram"></i></a>
                        <a href="#"><i class="bi bi-twitter-x"></i></a>
                        <a href="#"><i class="bi bi-youtube"></i></a>
                    </div>
                </div>
                <div class="col-6 col-lg-2">
                    <h5>Liên kết</h5>
                    <ul class="footer-links">
                        <li><a href="#hero">Trang chủ</a></li>
                        <li><a href="#rooms">Phòng nghỉ</a></li>
                        <li><a href="#amenities">Tiện nghi</a></li>
                        <li><a href="#testimonials">Đánh giá</a></li>
                    </ul>
                </div>
                <div class="col-6 col-lg-2">
                    <h5>Hỗ trợ</h5>
                    <ul class="footer-links">
                        <li><a href="#">Chính sách</a></li>
                        <li><a href="#">Điều khoản</a></li>
                        <li><a href="#">FAQ</a></li>
                        <li><a href="#">Liên hệ</a></li>
                    </ul>
                </div>
                <div class="col-lg-4">
                    <h5>Liên hệ</h5>
                    <div class="footer-contact">
                        <p><i class="bi bi-geo-alt"></i> 123 Đường ABC, Quận 1, TP.HCM</p>
                        <p><i class="bi bi-telephone"></i> (028) 1234 5678</p>
                        <p><i class="bi bi-envelope"></i> info@luxuryhotel.vn</p>
                    </div>
                </div>
            </div>
            <div class="footer-bottom">
                <p>&copy; 2026 Luxury Hotel. Bảo lưu mọi quyền.</p>
            </div>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Navbar scroll effect with smooth transition
        window.addEventListener('scroll', function() {
            const navbar = document.getElementById('mainNav');
            if (window.scrollY > 50) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
        });

        // Smooth scroll for anchor links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function(e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({ behavior: 'smooth', block: 'start' });
                }
            });
        });

        // Scroll-reveal animation using IntersectionObserver
        (function initScrollReveal() {
            const reveals = document.querySelectorAll('.scroll-reveal');
            if (!reveals.length) return;

            const observer = new IntersectionObserver(function(entries) {
                entries.forEach(function(entry) {
                    if (entry.isIntersecting) {
                        entry.target.classList.add('revealed');
                        observer.unobserve(entry.target);
                    }
                });
            }, { threshold: 0.15, rootMargin: '0px 0px -40px 0px' });

            reveals.forEach(function(el) { observer.observe(el); });
        })();

        // Testimonial Carousel
        (function initCarousel() {
            var track = document.getElementById('testimonialTrack');
            var dotsContainer = document.getElementById('carouselDots');
            var prevBtn = document.getElementById('prevBtn');
            var nextBtn = document.getElementById('nextBtn');
            if (!track || !dotsContainer) return;

            var slides = track.querySelectorAll('.testimonial-slide');
            var totalSlides = slides.length;
            if (totalSlides === 0) return;

            var currentIndex = 0;
            var slidesPerView = getSlidesPerView();
            var totalPages = Math.ceil(totalSlides / slidesPerView);
            var autoplayTimer = null;

            function getSlidesPerView() {
                if (window.innerWidth >= 992) return 3;
                if (window.innerWidth >= 768) return 2;
                return 1;
            }

            function buildDots() {
                dotsContainer.innerHTML = '';
                for (var i = 0; i < totalPages; i++) {
                    var dot = document.createElement('button');
                    dot.className = 'carousel-dot' + (i === currentIndex ? ' active' : '');
                    dot.setAttribute('aria-label', 'Page ' + (i + 1));
                    dot.dataset.index = i;
                    dot.addEventListener('click', function() {
                        goToPage(parseInt(this.dataset.index));
                    });
                    dotsContainer.appendChild(dot);
                }
            }

            function goToPage(page) {
                currentIndex = Math.max(0, Math.min(page, totalPages - 1));
                var offset = currentIndex * (100 / totalPages) * totalPages / (totalSlides / slidesPerView);
                // Calculate percentage based on slides
                var slideWidth = 100 / slidesPerView;
                var translateX = currentIndex * slidesPerView * slideWidth;
                // Clamp to avoid going past last slide
                var maxTranslate = (totalSlides - slidesPerView) * slideWidth;
                translateX = Math.min(translateX, maxTranslate);
                track.style.transform = 'translateX(-' + translateX + '%)';

                // Update dots
                var dots = dotsContainer.querySelectorAll('.carousel-dot');
                dots.forEach(function(d, i) {
                    d.classList.toggle('active', i === currentIndex);
                });

                // Update button states
                if (prevBtn) prevBtn.classList.toggle('disabled', currentIndex === 0);
                if (nextBtn) nextBtn.classList.toggle('disabled', currentIndex >= totalPages - 1);

                resetAutoplay();
            }

            function nextPage() {
                goToPage(currentIndex + 1 >= totalPages ? 0 : currentIndex + 1);
            }

            function prevPage() {
                goToPage(currentIndex - 1 < 0 ? totalPages - 1 : currentIndex - 1);
            }

            function resetAutoplay() {
                if (autoplayTimer) clearInterval(autoplayTimer);
                autoplayTimer = setInterval(nextPage, 5000);
            }

            // Set slide widths
            function setSlideSizes() {
                slidesPerView = getSlidesPerView();
                totalPages = Math.ceil(totalSlides / slidesPerView);
                var width = (100 / slidesPerView);
                slides.forEach(function(s) {
                    s.style.minWidth = width + '%';
                    s.style.maxWidth = width + '%';
                });
                buildDots();
                goToPage(Math.min(currentIndex, totalPages - 1));
            }

            // Event listeners
            if (prevBtn) prevBtn.addEventListener('click', prevPage);
            if (nextBtn) nextBtn.addEventListener('click', nextPage);

            // Touch/swipe support
            var touchStartX = 0;
            var touchEndX = 0;
            track.addEventListener('touchstart', function(e) {
                touchStartX = e.changedTouches[0].screenX;
            }, { passive: true });
            track.addEventListener('touchend', function(e) {
                touchEndX = e.changedTouches[0].screenX;
                var diff = touchStartX - touchEndX;
                if (Math.abs(diff) > 50) {
                    if (diff > 0) nextPage();
                    else prevPage();
                }
            }, { passive: true });

            // Pause on hover
            track.addEventListener('mouseenter', function() {
                if (autoplayTimer) clearInterval(autoplayTimer);
            });
            track.addEventListener('mouseleave', resetAutoplay);

            // Init
            setSlideSizes();
            window.addEventListener('resize', function() {
                setSlideSizes();
            });
        })();
    </script>
</body>
</html>
