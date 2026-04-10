package com.mycompany.hotelmanagementsystem.service;

import com.mycompany.hotelmanagementsystem.entity.Feedback;
import com.mycompany.hotelmanagementsystem.dal.FeedbackRepository;
import java.util.List;

public class AdminFeedbackService {
    private final FeedbackRepository feedbackRepository;

    public AdminFeedbackService() {
        this.feedbackRepository = new FeedbackRepository();
    }

    public List<Feedback> getAllFeedback() {
        return feedbackRepository.findAllWithDetails();
    }

    public List<Feedback> getVisibleFeedback(int limit) {
        return feedbackRepository.findVisibleWithDetails(limit);
    }

    public boolean toggleVisibility(int feedbackId) {
        Feedback feedback = feedbackRepository.findById(feedbackId);
        if (feedback == null) return false;
        return feedbackRepository.updateIsHidden(feedbackId, !feedback.isHidden()) > 0;
    }

    public boolean replyToFeedback(int feedbackId, int adminId, String reply) {
        return feedbackRepository.upsertReply(feedbackId, adminId, reply) > 0;
    }
}
