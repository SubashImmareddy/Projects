package com.subash.labelreader;

import android.Manifest;
import android.app.Dialog;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.media.AudioManager;
import android.media.ToneGenerator;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.view.MotionEvent;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.OptIn;
import androidx.appcompat.app.AppCompatActivity;
import androidx.camera.core.Camera;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.ExperimentalGetImage;
import androidx.camera.core.FocusMeteringAction;
import androidx.camera.core.ImageCapture;
import androidx.camera.core.ImageCaptureException;
import androidx.camera.core.ImageProxy;
import androidx.camera.core.MeteringPoint;
import androidx.camera.core.Preview;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.camera.view.PreviewView;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.google.common.util.concurrent.ListenableFuture;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.text.TextRecognizer;
import com.google.mlkit.vision.text.TextRecognition;
import com.google.mlkit.vision.text.latin.TextRecognizerOptions;

import java.util.Locale;
import java.util.concurrent.TimeUnit;

public class MainActivity extends AppCompatActivity {

    private PreviewView previewView;
    private TextView tvMRP, tvExpiry, tvMfg;
    private TextView tvScanStatus, tvReset, btnSettings, tvRawBtn;
    private Button btnScan1, btnScan2, btnTorch;
    private LinearLayout rootLayout, infoPanel;
    private LinearLayout mrpBox, mfgBox, expiryBox;
    private LinearLayout scan1Wrapper, scan2Wrapper, btnTorchWrapper;
    private ImageCapture imageCapture;
    private Camera camera;
    private TextToSpeech tts;
    private ToneGenerator toneGenerator;

    // Reuse recognizer — created once, no lag
    private TextRecognizer textRecognizer;

    private boolean isTorchOn = false;
    private String rawText1   = null;
    private String rawText2   = null;

    private static final int PERMISSION_REQUEST_CODE = 100;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        ThemeManager.applyTheme(this);
        super.onCreate(savedInstanceState);

        getWindow().setFlags(
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS);

        setContentView(R.layout.activity_main);

        previewView    = findViewById(R.id.previewView);
        tvMRP          = findViewById(R.id.tvMRP);
        tvExpiry       = findViewById(R.id.tvExpiry);
        tvMfg          = findViewById(R.id.tvMfg);
        tvScanStatus   = findViewById(R.id.tvScanStatus);
        tvReset        = findViewById(R.id.tvReset);
        btnSettings    = findViewById(R.id.btnSettings);
        tvRawBtn       = findViewById(R.id.tvRawBtn);
        btnScan1       = findViewById(R.id.btnScan1);
        btnScan2       = findViewById(R.id.btnScan2);
        btnTorch       = findViewById(R.id.btnTorch);
        rootLayout     = findViewById(R.id.rootLayout);
        infoPanel      = findViewById(R.id.infoPanel);
        mrpBox         = findViewById(R.id.mrpBox);
        mfgBox         = findViewById(R.id.mfgBox);
        expiryBox      = findViewById(R.id.expiryBox);
        scan1Wrapper   = findViewById(R.id.scan1Wrapper);
        scan2Wrapper   = findViewById(R.id.scan2Wrapper);
        btnTorchWrapper = findViewById(R.id.btnTorchWrapper);

        // Create recognizer ONCE — key fix for lag
        textRecognizer = TextRecognition.getClient(
                TextRecognizerOptions.DEFAULT_OPTIONS);

        applyThemeColors();

        tts = new TextToSpeech(this, status -> {
            if (status == TextToSpeech.SUCCESS)
                tts.setLanguage(Locale.ENGLISH);
        });

        toneGenerator = new ToneGenerator(AudioManager.STREAM_MUSIC, 100);

        btnSettings.setOnClickListener(v ->
                startActivity(new Intent(this, SettingsActivity.class)));

        btnTorch.setOnClickListener(v -> toggleTorch());

        btnScan1.setOnClickListener(v -> {
            tvScanStatus.setText("⏳ Scanning...");
            btnScan1.setEnabled(false);
            captureOCR(1);
        });

        btnScan2.setOnClickListener(v -> {
            tvScanStatus.setText("⏳ Scanning...");
            btnScan2.setEnabled(false);
            captureOCR(2);
        });

        tvReset.setOnClickListener(v -> resetAll());
        tvRawBtn.setOnClickListener(v -> showRawDialog());

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA)
                == PackageManager.PERMISSION_GRANTED) {
            startCamera();
        } else {
            ActivityCompat.requestPermissions(this,
                    new String[]{Manifest.permission.CAMERA},
                    PERMISSION_REQUEST_CODE);
        }
    }

    private void showRawDialog() {
        String raw = "";
        if (rawText1 != null) raw += "— Scan 1 —\n" + rawText1;
        if (rawText2 != null) raw += "\n\n— Scan 2 —\n" + rawText2;
        if (raw.isEmpty()) raw = "No scan data yet.";

        Dialog dialog = new Dialog(this);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(R.layout.dialog_raw_text);
        dialog.getWindow().setBackgroundDrawable(
                new ColorDrawable(Color.TRANSPARENT));
        dialog.getWindow().setLayout(
                (int)(getResources().getDisplayMetrics().widthPixels * 0.88),
                WindowManager.LayoutParams.WRAP_CONTENT);

        ((TextView) dialog.findViewById(R.id.tvDialogContent)).setText(raw);
        dialog.findViewById(R.id.tvDialogClose)
                .setOnClickListener(v -> dialog.dismiss());
        dialog.show();
    }

    private void applyThemeColors() {
        int theme = ThemeManager.getSavedTheme(this);

        if (theme == ThemeManager.THEME_ACCESSIBILITY) {
            rootLayout.setBackgroundColor(Color.BLACK);
            infoPanel.setBackgroundColor(Color.BLACK);
            mrpBox.setBackgroundResource(R.drawable.card_access);
            mfgBox.setBackgroundResource(R.drawable.card_access);
            expiryBox.setBackgroundResource(R.drawable.card_access);
            btnSettings.setTextColor(Color.parseColor("#FFFF00"));
            tvScanStatus.setTextColor(Color.parseColor("#FFFF00"));
            tvReset.setTextColor(Color.parseColor("#FFFF00"));
            tvRawBtn.setTextColor(Color.parseColor("#FFFF00"));
            tvMRP.setTextColor(Color.parseColor("#FFFF00"));
            tvMfg.setTextColor(Color.WHITE);
            tvExpiry.setTextColor(Color.parseColor("#00FF00"));
            scan1Wrapper.setBackgroundColor(Color.parseColor("#FFFF00"));
            btnScan1.setTextColor(Color.BLACK);
            btnScan2.setTextColor(Color.parseColor("#888888"));
            btnTorchWrapper.setBackgroundColor(Color.parseColor("#1A1A1A"));
            tvMRP.setTextSize(20); tvMfg.setTextSize(18); tvExpiry.setTextSize(18);
        } else {
            rootLayout.setBackgroundColor(Color.parseColor("#121212"));
            infoPanel.setBackgroundColor(Color.parseColor("#121212"));
            mrpBox.setBackgroundResource(R.drawable.card_dark);
            mfgBox.setBackgroundResource(R.drawable.card_dark);
            expiryBox.setBackgroundResource(R.drawable.card_dark);
            btnSettings.setTextColor(Color.WHITE);
            tvScanStatus.setTextColor(Color.parseColor("#BB86FC"));
            tvReset.setTextColor(Color.parseColor("#444466"));
            tvRawBtn.setTextColor(Color.parseColor("#444466"));
            tvMRP.setTextColor(Color.parseColor("#BB86FC"));
            tvMfg.setTextColor(Color.WHITE);
            tvExpiry.setTextColor(Color.parseColor("#03DAC6"));
            scan1Wrapper.setBackgroundResource(R.drawable.btn_gold);
            btnScan1.setTextColor(Color.WHITE);
            btnScan2.setTextColor(Color.parseColor("#666666"));
            btnTorchWrapper.setBackgroundResource(R.drawable.btn_grey);
            tvMRP.setTextSize(17); tvMfg.setTextSize(15); tvExpiry.setTextSize(15);
        }
    }

    private void toggleTorch() {
        isTorchOn = !isTorchOn;
        if (camera != null) camera.getCameraControl().enableTorch(isTorchOn);
        btnTorch.setText(isTorchOn ? "💡" : "🔦");
    }

    private void startCamera() {
        ListenableFuture<ProcessCameraProvider> future =
                ProcessCameraProvider.getInstance(this);

        future.addListener(() -> {
            try {
                ProcessCameraProvider cp = future.get();
                Preview preview = new Preview.Builder().build();
                preview.setSurfaceProvider(previewView.getSurfaceProvider());

                imageCapture = new ImageCapture.Builder()
                        .setCaptureMode(ImageCapture.CAPTURE_MODE_MAXIMIZE_QUALITY)
                        .build();

                cp.unbindAll();
                camera = cp.bindToLifecycle(this,
                        CameraSelector.DEFAULT_BACK_CAMERA, preview, imageCapture);

                startContinuousFocus();

                previewView.setOnTouchListener((v, event) -> {
                    if (event.getAction() == MotionEvent.ACTION_DOWN) {
                        MeteringPoint p = previewView
                                .getMeteringPointFactory()
                                .createPoint(event.getX(), event.getY());
                        camera.getCameraControl().startFocusAndMetering(
                                new FocusMeteringAction.Builder(p)
                                        .setAutoCancelDuration(3, TimeUnit.SECONDS)
                                        .build());
                    }
                    return true;
                });

            } catch (Exception e) { e.printStackTrace(); }
        }, ContextCompat.getMainExecutor(this));
    }

    private void startContinuousFocus() {
        if (camera == null) return;
        try {
            MeteringPoint p = previewView
                    .getMeteringPointFactory().createPoint(0.5f, 0.5f);
            camera.getCameraControl().startFocusAndMetering(
                    new FocusMeteringAction.Builder(p, FocusMeteringAction.FLAG_AF)
                            .setAutoCancelDuration(2, TimeUnit.SECONDS).build());
        } catch (Exception e) { e.printStackTrace(); }
    }

    @OptIn(markerClass = ExperimentalGetImage.class)
    private void captureOCR(int scanNumber) {
        if (imageCapture == null) return;

        imageCapture.takePicture(ContextCompat.getMainExecutor(this),
                new ImageCapture.OnImageCapturedCallback() {
                    @Override
                    public void onCaptureSuccess(ImageProxy image) {
                        InputImage input = InputImage.fromMediaImage(
                                image.getImage(),
                                image.getImageInfo().getRotationDegrees());

                        // Reuse recognizer — no new object creation
                        textRecognizer.process(input)
                                .addOnSuccessListener(visionText -> {
                                    String raw = visionText.getText();
                                    image.close();

                                    toneGenerator.startTone(
                                            ToneGenerator.TONE_CDMA_ALERT_CALL_GUARD, 200);

                                    if (scanNumber == 1) {
                                        rawText1 = raw;
                                        btnScan1.setEnabled(true);
                                        btnScan2.setEnabled(true);
                                        btnScan2.setTextColor(Color.WHITE);
                                        scan2Wrapper.setBackgroundResource(R.drawable.btn_purple);
                                        tvScanStatus.setText("✅ Done. Flip → SCAN 2 for more.");
                                    } else {
                                        rawText2 = raw;
                                        btnScan2.setEnabled(true);
                                        tvScanStatus.setText("✅ Scan 2 done.");
                                    }

                                    processAndDisplay();
                                    startContinuousFocus();
                                })
                                .addOnFailureListener(e -> {
                                    tvScanStatus.setText("❌ Scan failed. Try again.");
                                    btnScan1.setEnabled(true);
                                    btnScan2.setEnabled(rawText1 != null);
                                    image.close();
                                });
                    }

                    @Override
                    public void onError(ImageCaptureException e) {
                        tvScanStatus.setText("❌ Camera error. Try again.");
                        btnScan1.setEnabled(true);
                    }
                });
    }

    private void processAndDisplay() {
        StringBuilder sb = new StringBuilder();
        if (rawText1 != null) sb.append(rawText1).append("\n");
        if (rawText2 != null) sb.append(rawText2).append("\n");

        String merged = sb.toString().trim();
        if (merged.isEmpty()) return;

        LabelExtractor.LabelResult label = LabelExtractor.parseAll(merged);

        tvMRP.setText(label.mrp != null ? label.mrp : "—");
        tvMfg.setText(label.mfgDate != null ? label.mfgDate : "—");

        if (label.expiryDate != null) {
            String d = label.expiryDate;
            if ("calculated".equals(label.expirySource)) d += "*";
            tvExpiry.setText(d);
        } else {
            tvExpiry.setText("—");
        }

        speak(SpeechHelper.buildSpeech(label.mrp, label.expiryDate, label.mfgDate));
    }

    private void resetAll() {
        rawText1 = null;
        rawText2 = null;
        tvMRP.setText("—");
        tvMfg.setText("—");
        tvExpiry.setText("—");
        tvScanStatus.setText("Point camera at product label");
        btnScan1.setEnabled(true);
        btnScan2.setEnabled(false);
        btnScan2.setTextColor(Color.parseColor("#666666"));
        scan2Wrapper.setBackgroundResource(R.drawable.btn_grey);
        if (isTorchOn && camera != null) {
            camera.getCameraControl().enableTorch(false);
            isTorchOn = false;
            btnTorch.setText("🔦");
        }
    }

    private void speak(String text) {
        tts.speak(text, TextToSpeech.QUEUE_FLUSH, null, "scan_result");
    }

    @Override
    protected void onResume() {
        super.onResume();
        applyThemeColors();
    }

    @Override
    protected void onDestroy() {
        if (tts != null) { tts.stop(); tts.shutdown(); }
        if (toneGenerator != null) toneGenerator.release();
        if (textRecognizer != null) textRecognizer.close();
        super.onDestroy();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == PERMISSION_REQUEST_CODE
                && grantResults.length > 0
                && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            startCamera();
        }
    }
}