package com.subash.labelreader;

import android.content.Context;
import android.content.SharedPreferences;

public class ThemeManager {

    public static final int THEME_DARK         = 0;
    public static final int THEME_LIGHT        = 1;
    public static final int THEME_ACCESSIBILITY = 2;

    private static final String PREF_NAME = "visionmate_prefs";
    private static final String KEY_THEME  = "theme";

    public static void saveTheme(Context context, int theme) {
        context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
                .edit().putInt(KEY_THEME, theme).apply();
    }

    public static int getSavedTheme(Context context) {
        return context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
                .getInt(KEY_THEME, THEME_DARK);
    }

    public static void applyTheme(Context context) {
        int theme = getSavedTheme(context);
        if (theme == THEME_LIGHT) {
            ((android.app.Activity) context).setTheme(R.style.Theme_LabelReader_Light);
        } else if (theme == THEME_ACCESSIBILITY) {
            ((android.app.Activity) context).setTheme(R.style.Theme_LabelReader_Accessibility);
        } else {
            ((android.app.Activity) context).setTheme(R.style.Theme_LabelReader_Dark);
        }
    }

    // Returns colors based on current theme
    public static int getBackground(Context context) {
        int theme = getSavedTheme(context);
        if (theme == THEME_LIGHT) return android.graphics.Color.parseColor("#F5F5F5");
        if (theme == THEME_ACCESSIBILITY) return android.graphics.Color.BLACK;
        return android.graphics.Color.parseColor("#0D0D0D");
    }

    public static int getPanelColor(Context context) {
        int theme = getSavedTheme(context);
        if (theme == THEME_LIGHT) return android.graphics.Color.parseColor("#FFFFFF");
        if (theme == THEME_ACCESSIBILITY) return android.graphics.Color.parseColor("#1A1A1A");
        return android.graphics.Color.parseColor("#1A1A1A");
    }

    public static int getAccent(Context context) {
        int theme = getSavedTheme(context);
        if (theme == THEME_LIGHT) return android.graphics.Color.parseColor("#6200EE");
        if (theme == THEME_ACCESSIBILITY) return android.graphics.Color.parseColor("#FFFF00");
        return android.graphics.Color.parseColor("#FFD700");
    }

    public static int getPrimaryText(Context context) {
        int theme = getSavedTheme(context);
        if (theme == THEME_LIGHT) return android.graphics.Color.parseColor("#000000");
        return android.graphics.Color.WHITE;
    }
}