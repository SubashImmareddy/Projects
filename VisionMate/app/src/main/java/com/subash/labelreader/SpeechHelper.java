package com.subash.labelreader;

public class SpeechHelper {

    private static final String[] MONTHS_EN = {
            "", "January", "February", "March", "April",
            "May", "June", "July", "August", "September",
            "October", "November", "December"
    };

    private static final String[] MONTHS_TE = {
            "", "జనవరి", "ఫిబ్రవరి", "మార్చి", "ఏప్రిల్",
            "మే", "జూన్", "జులై", "ఆగస్టు", "సెప్టెంబర్",
            "అక్టోబర్", "నవంబర్", "డిసెంబర్"
    };

    public static String speakMRP(String mrp, boolean telugu) {
        if (mrp == null) return telugu ? "ధర దొరకలేదు" : "Price not found";
        String cleaned = mrp.replaceAll("\\.00$", "")
                .replaceAll("[₹,]", "").trim();
        return telugu ? cleaned + " రూపాయలు" : cleaned + " rupees";
    }

    public static String speakDate(String date, boolean telugu) {
        if (date == null) return telugu ? "దొరకలేదు" : "not found";
        try {
            String[] parts = date.split("[/\\-]");
            if (parts.length == 2) {
                int month = Integer.parseInt(parts[0].trim());
                String yearPart = parts[1].trim();
                if (yearPart.length() == 2) yearPart = "20" + yearPart;
                if (month >= 1 && month <= 12) {
                    String[] months = telugu ? MONTHS_TE : MONTHS_EN;
                    return months[month] + " " + yearPart;
                }
            }
        } catch (Exception e) {
            // fallback
        }
        return date;
    }

    public static String buildSpeech(String mrp, String expiry,
                                     String mfg, boolean telugu) {
        StringBuilder sb = new StringBuilder();

        if (telugu) {
            sb.append("ధర ").append(speakMRP(mrp, true)).append(". ");
            if (mfg != null)
                sb.append("తయారీ తేదీ ").append(speakDate(mfg, true)).append(". ");
            if (expiry != null)
                sb.append("గడువు తేదీ ").append(speakDate(expiry, true)).append(". ");
            else
                sb.append("గడువు తేదీ దొరకలేదు. ");
            if (mrp == null || expiry == null)
                sb.append("దయచేసి ప్యాకెట్ పై భాగం లేదా కింది భాగం చూపించండి.");
        } else {
            sb.append("MRP is ").append(speakMRP(mrp, false)).append(". ");
            if (mfg != null)
                sb.append("Manufactured in ").append(speakDate(mfg, false)).append(". ");
            if (expiry != null)
                sb.append("It expires in ").append(speakDate(expiry, false)).append(". ");
            else
                sb.append("Expiry date not found. ");
            if (mrp == null || expiry == null)
                sb.append("Please point camera at top or bottom of pack and scan again.");
        }

        return sb.toString();
    }
}