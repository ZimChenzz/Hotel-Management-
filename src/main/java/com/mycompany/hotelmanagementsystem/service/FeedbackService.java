package com.mycompany.hotelmanagementsystem.service;

import com.mycompany.hotelmanagementsystem.constant.BookingStatus;
import com.mycompany.hotelmanagementsystem.util.ServiceResult;
import com.mycompany.hotelmanagementsystem.util.ValidationHelper;
import com.mycompany.hotelmanagementsystem.entity.Booking;
import com.mycompany.hotelmanagementsystem.entity.Feedback;
import com.mycompany.hotelmanagementsystem.dal.BookingRepository;
import com.mycompany.hotelmanagementsystem.dal.FeedbackRepository;

public class FeedbackService {
    private final FeedbackRepository feedbackRepository;
    private final BookingRepository bookingRepository;

    public FeedbackService() {
        this.feedbackRepository = new FeedbackRepository();
        this.bookingRepository = new BookingRepository();
    }

    // Dùng Feedback entity thay cho FeedbackRequest
    public ServiceResult submitFeedback(int customerId, Feedback feedback) {
        Booking booking = bookingRepository.findById(feedback.getBookingId());
        if (booking == null || booking.getCustomerId() != customerId) {
            return ServiceResult.failure("Không tìm thấy đặt phòng");
        }

        if (!BookingStatus.CHECKED_OUT.equals(booking.getStatus()) &&
            !BookingStatus.CONFIRMED.equals(booking.getStatus())) {
            return ServiceResult.failure("Chỉ có thể đánh giá sau khi hoàn thành đặt phòng");
        }

        if (feedbackRepository.existsByBookingId(feedback.getBookingId())) {
            return ServiceResult.failure("Bạn đã đánh giá đặt phòng này rồi");
        }

        if (feedback.getRating() < 1 || feedback.getRating() > 5) {
            return ServiceResult.failure("Đánh giá phải từ 1 đến 5 sao");
        }

        String comment = ValidationHelper.sanitize(feedback.getComment());
        if (comment != null && comment.length() > 1000) {
            comment = comment.substring(0, 1000);
        }
        feedback.setComment(comment);

        int feedbackId = feedbackRepository.insert(feedback);
        if (feedbackId <= 0) {
            return ServiceResult.failure("Không thể gửi đánh giá");
        }

        return ServiceResult.success("Cảm ơn bạn đã đánh giá!");
    }

    public Feedback getBookingFeedback(int bookingId) {
        return feedbackRepository.findByBookingId(bookingId);
    }

    public boolean hasFeedback(int bookingId) {
        return feedbackRepository.existsByBookingId(bookingId);
    }

    // Dùng Feedback entity thay cho FeedbackRequest
    public ServiceResult updateFeedback(int feedbackId, int customerId, Feedback newFeedback) {
        Feedback feedback = feedbackRepository.findById(feedbackId);
        if (feedback == null) {
            return ServiceResult.failure("Không tìm thấy đánh giá");
        }
        Booking booking = bookingRepository.findById(feedback.getBookingId());
        if (booking == null || booking.getCustomerId() != customerId) {
            return ServiceResult.failure("Bạn không có quyền chỉnh sửa đánh giá này");
        }
        if (newFeedback.getRating() < 1 || newFeedback.getRating() > 5) {
            return ServiceResult.failure("Đánh giá phải từ 1 đến 5 sao");
        }
        String comment = ValidationHelper.sanitize(newFeedback.getComment());
        if (comment != null && comment.length() > 1000) {
            comment = comment.substring(0, 1000);
        }
        feedback.setRating(newFeedback.getRating());
        feedback.setComment(comment);
        if (feedbackRepository.update(feedback) > 0) {
            return ServiceResult.success("Cập nhật đánh giá thành công");
        }
        return ServiceResult.failure("Không thể cập nhật đánh giá");
    }

    public ServiceResult deleteFeedback(int feedbackId, int customerId) {
        Feedback feedback = feedbackRepository.findById(feedbackId);
        if (feedback == null) {
            return ServiceResult.failure("Không tìm thấy đánh giá");
        }
        Booking booking = bookingRepository.findById(feedback.getBookingId());
        if (booking == null || booking.getCustomerId() != customerId) {
            return ServiceResult.failure("Bạn không có quyền xóa đánh giá này");
        }
        if (feedbackRepository.delete(feedbackId) > 0) {
            return ServiceResult.success("Đánh giá đã được xóa thành công");
        }
        return ServiceResult.failure("Không thể xóa đánh giá");
    }
}
