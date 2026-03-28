package com.subash.labelreader;

public class SpeechHelper {

    private static final String[] MONTHS = {
            "", "January", "February", "March", "April",
            "May", "June", "July", "August", "September",
            "October", "November", "December"
    };

    public static String speakMRP(String mrp) {
        if (mrp == null) return "Price not found";
        String cleaned = mrp.replaceAll("\\.00$", "")
                .replaceAll("[₹,]", "")
                .trim();
        // Remove decimals if .00
        if (cleaned.endsWith(".00")) {
            cleaned = cleaned.replace(".00", "");
        }
        return cleaned + " rupees";
    }

    public static String speakDate(String date) {
        if (date == null) return "not found";
        try {
            String[] parts = date.split("[/\\-]");
            if (parts.length == 2) {
                int month = Integer.parseInt(parts[0].trim());
                String yearPart = parts[1].trim();
                if (yearPart.length() == 2) yearPart = "20" + yearPart;
                if (month >= 1 && month <= 12) {
                    return MONTHS[month] + " " + yearPart;
                }
            }
        } catch (Exception e) {
            // fallback to raw
        }
        return date;
    }

    public static String buildSpeech(String mrp, String expiry, String mfg) {
        StringBuilder sb = new StringBuilder();

        // MRP
        if (mrp != null) {
            sb.append("The MRP is ").append(speakMRP(mrp)).append(". ");
        } else {
            sb.append("Price not found. ");
        }

        // Mfg date
        if (mfg != null) {
            sb.append("This product was manufactured in ")
                    .append(speakDate(mfg)).append(". ");
        }

        // Expiry
        if (expiry != null) {
            sb.append("It expires in ").append(speakDate(expiry)).append(". ");
        } else {
            sb.append("Expiry date not found. ");
        }

        // Guidance if something missing
        if (mrp == null || expiry == null) {
            sb.append("If details are missing, please point the camera at the top or bottom of the pack and scan again.");
        }

        return sb.toString();
    }
}