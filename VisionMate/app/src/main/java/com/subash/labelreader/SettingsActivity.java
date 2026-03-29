package com.subash.labelreader;

import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

public class SettingsActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        ThemeManager.applyTheme(this);
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_settings);

        LinearLayout settingsRoot   = findViewById(R.id.settingsRoot);
        LinearLayout settingsTopBar = findViewById(R.id.settingsTopBar);
        TextView tvBack    = findViewById(R.id.tvBack);
        TextView tvGithub  = findViewById(R.id.tvGithub);
        Button btnDark     = findViewById(R.id.btnThemeDark);
        Button btnAccess   = findViewById(R.id.btnThemeAccess);
        Button btnEnglish  = findViewById(R.id.btnLangEnglish);
        Button btnTelugu   = findViewById(R.id.btnLangTelugu);

        // Apply theme
        int theme  = ThemeManager.getSavedTheme(this);
        int bg     = theme == ThemeManager.THEME_ACCESSIBILITY
                ? Color.BLACK : Color.parseColor("#121212");
        int topBg  = theme == ThemeManager.THEME_ACCESSIBILITY
                ? Color.BLACK : Color.parseColor("#1E1E1E");
        int accent = theme == ThemeManager.THEME_ACCESSIBILITY
                ? Color.parseColor("#FFFF00")
                : Color.parseColor("#BB86FC");
        int title  = theme == ThemeManager.THEME_ACCESSIBILITY
                ? Color.parseColor("#FFFF00") : Color.WHITE;

        settingsRoot.setBackgroundColor(bg);
        settingsTopBar.setBackgroundColor(topBg);
        tvBack.setTextColor(accent);
        tvGithub.setTextColor(accent);

        TextView tvTitle = (TextView) settingsTopBar.getChildAt(1);
        if (tvTitle != null) tvTitle.setTextColor(title);

        // Highlight active theme
        int active   = Color.parseColor("#BB86FC");
        int inactive = Color.parseColor("#2C2C2C");

        btnDark.setBackgroundTintList(ColorStateList.valueOf(
                theme == ThemeManager.THEME_DARK ? active : inactive));
        btnAccess.setBackgroundTintList(ColorStateList.valueOf(
                theme == ThemeManager.THEME_ACCESSIBILITY ? active : inactive));

        // Highlight active language
        int lang = ThemeManager.getSavedLanguage(this);
        btnEnglish.setBackgroundTintList(ColorStateList.valueOf(
                lang == ThemeManager.LANG_ENGLISH ? active : inactive));
        btnTelugu.setBackgroundTintList(ColorStateList.valueOf(
                lang == ThemeManager.LANG_TELUGU ? active : inactive));

        // Click listeners
        tvBack.setOnClickListener(v -> finish());

        tvGithub.setOnClickListener(v ->
                startActivity(new Intent(Intent.ACTION_VIEW,
                        Uri.parse("https://github.com/SubashImmareddy/"))));

        btnDark.setOnClickListener(v -> {
            ThemeManager.saveTheme(this, ThemeManager.THEME_DARK);
            restart();
        });

        btnAccess.setOnClickListener(v -> {
            ThemeManager.saveTheme(this, ThemeManager.THEME_ACCESSIBILITY);
            restart();
        });

        btnEnglish.setOnClickListener(v -> {
            ThemeManager.saveLanguage(this, ThemeManager.LANG_ENGLISH);
            btnEnglish.setBackgroundTintList(
                    ColorStateList.valueOf(active));
            btnTelugu.setBackgroundTintList(
                    ColorStateList.valueOf(inactive));
            restart();
        });

        btnTelugu.setOnClickListener(v -> {
            ThemeManager.saveLanguage(this, ThemeManager.LANG_TELUGU);
            btnTelugu.setBackgroundTintList(
                    ColorStateList.valueOf(active));
            btnEnglish.setBackgroundTintList(
                    ColorStateList.valueOf(inactive));
            restart();
        });
    }

    private void restart() {
        Intent i = new Intent(this, MainActivity.class);
        i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK |
                Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(i);
        overridePendingTransition(
                android.R.anim.fade_in,
                android.R.anim.fade_out);
        finish();
    }
}