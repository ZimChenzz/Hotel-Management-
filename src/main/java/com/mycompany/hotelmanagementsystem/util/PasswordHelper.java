package com.mycompany.hotelmanagementsystem.util;

import org.mindrot.jbcrypt.BCrypt;

public final class PasswordHelper {
    private static final int COST_FACTOR = 12;
    // Ngưỡng tương đồng tối thiểu (70%) - mật khẩu mới phải khác đủ nhiều
    private static final double SIMILARITY_THRESHOLD = 0.7;

    private PasswordHelper() {}

    public static String hash(String password) {
        return BCrypt.hashpw(password, BCrypt.gensalt(COST_FACTOR));
    }

    public static boolean verify(String password, String hash) {
        return BCrypt.checkpw(password, hash);
    }

    /**
     * Kiểm tra mật khẩu mới có quá giống mật khẩu cũ không.
     * Sử dụng Levenshtein distance để đo độ tương đồng.
     * @return true nếu mật khẩu mới quá giống mật khẩu cũ (nên từ chối)
     */
    public static boolean isTooSimilar(String oldPassword, String newPassword) {
        if (oldPassword == null || newPassword == null) return false;

        // Giống hệt nhau
        if (oldPassword.equals(newPassword)) return true;

        // So sánh không phân biệt hoa thường
        if (oldPassword.equalsIgnoreCase(newPassword)) return true;

        // Tính Levenshtein distance
        double similarity = calculateSimilarity(oldPassword.toLowerCase(), newPassword.toLowerCase());
        return similarity >= SIMILARITY_THRESHOLD;
    }

    /**
     * Tính độ tương đồng giữa 2 chuỗi dựa trên Levenshtein distance.
     * @return giá trị từ 0.0 (hoàn toàn khác) đến 1.0 (giống hệt)
     */
    private static double calculateSimilarity(String s1, String s2) {
        int maxLen = Math.max(s1.length(), s2.length());
        if (maxLen == 0) return 1.0;
        int distance = levenshteinDistance(s1, s2);
        return 1.0 - ((double) distance / maxLen);
    }

    /**
     * Tính khoảng cách Levenshtein giữa 2 chuỗi.
     */
    private static int levenshteinDistance(String s1, String s2) {
        int len1 = s1.length();
        int len2 = s2.length();
        int[][] dp = new int[len1 + 1][len2 + 1];

        for (int i = 0; i <= len1; i++) dp[i][0] = i;
        for (int j = 0; j <= len2; j++) dp[0][j] = j;

        for (int i = 1; i <= len1; i++) {
            for (int j = 1; j <= len2; j++) {
                int cost = (s1.charAt(i - 1) == s2.charAt(j - 1)) ? 0 : 1;
                dp[i][j] = Math.min(
                    Math.min(dp[i - 1][j] + 1, dp[i][j - 1] + 1),
                    dp[i - 1][j - 1] + cost
                );
            }
        }
        return dp[len1][len2];
    }

    public static void main(String[] args) {
        System.out.println(hash("1"));
    }
}
