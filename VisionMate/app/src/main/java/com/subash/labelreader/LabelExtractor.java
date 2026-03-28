package com.subash.labelreader;

import java.util.Calendar;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class LabelExtractor {

    public static class LabelResult {
        public String mrp;
        public String mfgDate;
        public String expiryDate;
        public String expirySource;
    }

    private static String monthToNum(String month) {
        switch (month.toUpperCase().substring(0, 3)) {
            case "JAN": return "01"; case "FEB": return "02";
            case "MAR": return "03"; case "APR": return "04";
            case "MAY": return "05"; case "JUN": return "06";
            case "JUL": return "07"; case "AUG": return "08";
            case "SEP": return "09"; case "OCT": return "10";
            case "NOV": return "11"; case "DEC": return "12";
            default: return null;
        }
    }

    private static String normalizeDate(String raw) {
        if (raw == null) return null;
        raw = raw.trim().replaceAll("\\s+", " ");

        // MM/YY or MM/YYYY
        Matcher m1 = Pattern.compile("^([0-9]{1,2})[/\\-]([0-9]{2,4})$").matcher(raw);
        if (m1.matches()) {
            String year = m1.group(2);
            if (year.length() == 2) year = "20" + year;
            return String.format("%02d/%s", Integer.parseInt(m1.group(1)), year);
        }

        // MON.YY or MON YYYY — JUN.23 MAY2027
        Matcher m2 = Pattern.compile(
                "^([A-Za-z]{3})[./\\s]?([0-9]{2,4})$"
        ).matcher(raw);
        if (m2.matches()) {
            String num = monthToNum(m2.group(1));
            String year = m2.group(2);
            if (year.length() == 2) year = "20" + year;
            if (num != null) return num + "/" + year;
        }

        return raw;
    }

    // Fixes common OCR misreads in date strings
    private static String fixOcrDate(String raw) {
        if (raw == null) return null;
        // OCR reads 12/2022 as 1220 or 122022 — insert slash
        raw = raw.replaceAll("([0-9]{2})([0-9]{4})", "$1/$2");
        // Remove stray spaces inside date
        raw = raw.replaceAll("([0-9]{1,2})\\s*/\\s*([0-9]{2,4})", "$1/$2");
        return raw.trim();
    }

    public static LabelResult parseAll(String ocrText) {
        LabelResult result = new LabelResult();
        result.mrp = extractMRP(ocrText);

        assignDates(ocrText, result);

        // Calculate expiry from months if not found
        if (result.expiryDate == null && result.mfgDate != null) {
            Matcher m = Pattern.compile(
                    "(?i)([0-9]+)\\s*months?\\s*(?:from|of)\\s*" +
                            "(?:manufacture|mfg|mfd|manufacturing|manufactured|the date of manufacture)"
            ).matcher(ocrText);
            if (m.find()) {
                int months = Integer.parseInt(m.group(1));
                result.expiryDate = calculateExpiry(result.mfgDate, months);
                result.expirySource = "calculated";
            }
        }

        if (result.expiryDate == null) {
            result.expiryDate = extractDirectExpiry(ocrText);
            result.expirySource = "printed";
        }

        return result;
    }

    private static void assignDates(String ocrText, LabelResult result) {

        // Pattern 1: MFD.JUN.23 / EXP.MAY27 / MFG.JAN.2023
        Matcher dotFormat = Pattern.compile(
                "(?i)(mfd|mfg|exp|expiry|best before|use before|bb|ubd)" +
                        "[.:\\s]+([A-Za-z]{3})[.\\s]?([0-9]{2,4})"
        ).matcher(ocrText);
        while (dotFormat.find()) {
            String keyword = dotFormat.group(1).toUpperCase();
            String month   = dotFormat.group(2);
            String year    = dotFormat.group(3);
            if (year.length() == 2) year = "20" + year;
            String num = monthToNum(month);
            if (num == null) continue;
            String date = num + "/" + year;

            if (keyword.startsWith("MF")) {
                if (result.mfgDate == null) result.mfgDate = date;
            } else {
                if (result.expiryDate == null) {
                    result.expiryDate = date;
                    result.expirySource = "printed";
                }
            }
        }

        // Pattern 2: MFD. Date : 12/2022 or MFD Date: 12/2022
        // Also catches OCR misreads like "Dete 1220"
        if (result.mfgDate == null) {
            Matcher m = Pattern.compile(
                    "(?i)(?:mfd|mfg|mfg\\.|manufactured)[.:\\s]*" +
                            "(?:date|dat|dete|dte)?[.:\\s]*([0-9]{1,2}[/\\-][0-9]{2,4})"
            ).matcher(ocrText);
            if (m.find()) result.mfgDate = normalizeDate(fixOcrDate(m.group(1)));
        }

        // Pattern 3: MFD date where OCR merged numbers: "1220" = "12/2022"
        if (result.mfgDate == null) {
            Matcher m = Pattern.compile(
                    "(?i)(?:mfd|mfg|manufactured)[.:\\s]*(?:date|dat|dete|dte)?[.:\\s]*([0-9]{6,8})"
            ).matcher(ocrText);
            if (m.find()) {
                String raw = m.group(1);
                // Try to split as MMYYYY
                if (raw.length() == 6) {
                    result.mfgDate = raw.substring(0, 2) + "/" + raw.substring(2);
                }
            }
        }

        // Pattern 4: "Month Year of Import: 01/2023" — treat as mfg fallback
        if (result.mfgDate == null) {
            Matcher m = Pattern.compile(
                    "(?i)(?:month|year)[^:]{0,20}(?:import|mfg|manufacture)[^:]{0,5}:?\\s*([0-9]{1,2}[/\\-][0-9]{2,4})"
            ).matcher(ocrText);
            if (m.find()) result.mfgDate = normalizeDate(m.group(1));
        }

        // Pattern 5: Symbol dates #11/25 ^06/25
        Matcher symbolDate = Pattern.compile(
                "([#^*~@])\\s*([0-9]{1,2}[/\\-][0-9]{2,4})"
        ).matcher(ocrText);
        while (symbolDate.find()) {
            String symbol  = symbolDate.group(1);
            String date    = normalizeDate(symbolDate.group(2).trim());
            String meaning = findSymbolMeaning(ocrText, symbol);
            if (meaning != null) {
                if (meaning.equals("MFG") && result.mfgDate == null)
                    result.mfgDate = date;
                else if (meaning.equals("EXP") && result.expiryDate == null) {
                    result.expiryDate = date;
                    result.expirySource = "printed";
                }
            } else {
                if (result.mfgDate == null) result.mfgDate = date;
            }
        }
    }

    private static String findSymbolMeaning(String ocrText, String symbol) {
        String esc = Pattern.quote(symbol);
        Matcher m = Pattern.compile(
                esc + "\\s*(?:mfg|mfd|manufactured|manufacturing|date of mfg|date of manufacture|dom|packed|pkd)",
                Pattern.CASE_INSENSITIVE
        ).matcher(ocrText);
        if (m.find()) return "MFG";

        Matcher e = Pattern.compile(
                esc + "\\s*(?:exp|expiry|expiry date|best before|use before|bb|ubd|use by)",
                Pattern.CASE_INSENSITIVE
        ).matcher(ocrText);
        if (e.find()) return "EXP";
        return null;
    }

    private static String extractDirectExpiry(String ocrText) {
        // Remove mfg lines
        String cleaned = ocrText.replaceAll(
                "(?i)(mfd|mfg|manufactured|dom|pkd)[^\\n]*", ""
        );

        // Use Before / Use By / UBD — most common on Indian imports
        Matcher m0 = Pattern.compile(
                "(?i)(?:use\\s*before|use\\s*by|ubd|use\\s*by\\s*date)" +
                        "[:\\s.]*([0-9]{1,2}[/\\-][0-9]{2,4})"
        ).matcher(ocrText);
        if (m0.find()) return normalizeDate(m0.group(1).trim());

        // Use Before with month name: Use Before: Dec 2025
        Matcher m0b = Pattern.compile(
                "(?i)(?:use\\s*before|use\\s*by)[:\\s.]*([A-Za-z]{3}[\\s.,]+[0-9]{4})"
        ).matcher(ocrText);
        if (m0b.find()) return normalizeDate(m0b.group(1).trim());

        // EXP / Expiry / Best Before with numeric date
        Matcher m1 = Pattern.compile(
                "(?i)(?:exp(?:iry|iry date|date|y)?|best\\s*before|bb)" +
                        "[:\\s.]*([0-9]{1,2}[/\\-][0-9]{2,4})"
        ).matcher(cleaned);
        if (m1.find()) return normalizeDate(m1.group(1).trim());

        // EXP with month name
        Matcher m2 = Pattern.compile(
                "(?i)(?:exp(?:iry)?|best\\s*before|bb)" +
                        "[:\\s.]*([A-Za-z]{3,9}[\\s,]+[0-9]{4})"
        ).matcher(cleaned);
        if (m2.find()) return normalizeDate(m2.group(1).trim());

        // # date fallback
        Matcher m3 = Pattern.compile(
                "#\\s*([0-9]{1,2}[/\\-][0-9]{2,4})"
        ).matcher(ocrText);
        if (m3.find()) return normalizeDate(m3.group(1).trim());

        return null;
    }

    public static String extractMRP(String ocrText) {
        Matcher m0 = Pattern.compile(
                "(?i)new\\s+m\\.?r\\.?p\\.?[^0-9]{0,10}([0-9]+(?:[./][0-9]{0,2})?)"
        ).matcher(ocrText);
        if (m0.find()) return m0.group(1).replace("/", "");

        Matcher m1 = Pattern.compile(
                "(?i)m\\.?r\\.?p\\.?[^0-9]{0,10}([0-9]+(?:[./][0-9]{0,2})?)"
        ).matcher(ocrText);
        if (m1.find()) return m1.group(1).replace("/", "");

        Matcher m2 = Pattern.compile(
                "[₹]\\s*([0-9]+(?:[./][0-9]{0,2})?)"
        ).matcher(ocrText);
        if (m2.find()) return m2.group(1).replace("/", "");

        Matcher m3 = Pattern.compile(
                "(?i)rs\\.?\\s*([0-9]{1,4})/?-?"
        ).matcher(ocrText);
        if (m3.find()) return m3.group(1);

        Matcher m4 = Pattern.compile(
                "(?<![0-9])([0-9]{1,4})/-"
        ).matcher(ocrText);
        if (m4.find()) return m4.group(1);

        Matcher m5 = Pattern.compile(
                "(?<![0-9])([0-9]{1,4}\\.[0-9]{2})(?![0-9])"
        ).matcher(ocrText);
        if (m5.find()) return m5.group(1);

        return null;
    }

    private static String calculateExpiry(String mfgDate, int monthsToAdd) {
        try {
            String[] parts = mfgDate.split("[/\\-]");
            if (parts.length == 2) {
                int month = Integer.parseInt(parts[0].trim()) - 1;
                int year  = Integer.parseInt(parts[1].trim());
                if (year < 100) year += 2000;
                Calendar cal = Calendar.getInstance();
                cal.set(Calendar.MONTH, month);
                cal.set(Calendar.YEAR, year);
                cal.add(Calendar.MONTH, monthsToAdd);
                return String.format("%02d/%d",
                        cal.get(Calendar.MONTH) + 1,
                        cal.get(Calendar.YEAR));
            }
        } catch (Exception e) { /* fallback */ }
        return null;
    }
}