package BVIApplication;

import java.io.ByteArrayInputStream;
import java.io.FileInputStream;
import java.util.Collections;
import java.util.Date;

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.DataLine;
import javax.sound.sampled.LineUnavailableException;
import javax.sound.sampled.SourceDataLine;
import javax.swing.SwingUtilities;

import com.google.auth.oauth2.AccessToken;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.auth.oauth2.ServiceAccountCredentials;
import com.google.cloud.texttospeech.v1.*;
import com.google.protobuf.ByteString;

public class AudioOutputProcessor implements Runnable {
    
    private BVIModel model;
    private BVIView view;
    private TextToSpeechSettings settings;

    public AudioOutputProcessor(BVIView view) throws Exception {
        this.view = view;
        settings = initializeTTS();
    }

    public void setBVIApplication(BVIModel model) {
        this.model = model;
    }

    @Override
    public void run() {
        while (!model.stopSimulation) {
            try {
                AudioCommand command = model.commandQueue.take(); // Take the first in the queue
                if (command != null) {
                    updateQueueStateInUI(command, true);
                    try {
                        ByteString audioContent = synthesizeText(settings, command.getMessage());
                        if (audioContent != null && audioContent.size() > 0) {
                            playAudio(audioContent);
                        } else {
                            System.err.println("Failed to synthesize audio content.");
                        }
                    } catch (Exception e) {
                        System.err.println("Error synthesizing text: " + e.getMessage());
                    }
                    updateQueueStateInUI(command, false); // Reset or remove from queue
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                System.err.println("AudioOutputProcessor thread interrupted");
            }
        }
    }

    private TextToSpeechSettings initializeTTS() throws Exception {
        String serviceAccountPath = "tts-credentials.json";
        String accessTokenString = generateAccessToken(serviceAccountPath);

        Date tokenExpiration = new Date(System.currentTimeMillis() + 3600 * 1000); // 1-hour token validity
        AccessToken accessToken = new AccessToken(accessTokenString, tokenExpiration);
        GoogleCredentials credentials = GoogleCredentials.create(accessToken);

        return TextToSpeechSettings.newBuilder()
                .setCredentialsProvider(() -> credentials)
                .build();
    }

    private String generateAccessToken(String serviceAccountPath) throws Exception {
        try (FileInputStream serviceAccountStream = new FileInputStream(serviceAccountPath)) {
            GoogleCredentials credentials = ServiceAccountCredentials.fromStream(serviceAccountStream)
                    .createScoped(Collections.singletonList("https://www.googleapis.com/auth/cloud-platform"));
            credentials.refreshIfExpired();
            return credentials.getAccessToken().getTokenValue();
        }
    }

    private ByteString synthesizeText(TextToSpeechSettings settings, String text) throws Exception {
        try (TextToSpeechClient textToSpeechClient = TextToSpeechClient.create(settings)) {
            SynthesisInput input = SynthesisInput.newBuilder().setText(text).build();

            VoiceSelectionParams voice = VoiceSelectionParams.newBuilder()
                    .setLanguageCode("en-US")
                    .setSsmlGender(SsmlVoiceGender.NEUTRAL)
                    .build();

            AudioConfig audioConfig = AudioConfig.newBuilder()
                    .setAudioEncoding(AudioEncoding.LINEAR16)
                    .setSampleRateHertz(16000)
                    .build();

            SynthesizeSpeechResponse response = textToSpeechClient.synthesizeSpeech(input, voice, audioConfig);
            return response.getAudioContent();
        }
    }

    private void playAudio(ByteString audioContent) throws Exception {
        byte[] audioData = audioContent.toByteArray();
        AudioFormat format = new AudioFormat(16000, 16, 1, true, false);

        try (ByteArrayInputStream bais = new ByteArrayInputStream(audioData);
                AudioInputStream audioStream = new AudioInputStream(bais, format, audioData.length)) {

            DataLine.Info info = new DataLine.Info(SourceDataLine.class, format);
            if (!AudioSystem.isLineSupported(info)) {
                throw new LineUnavailableException("Audio line not supported for format: " + format);
            }

            try (SourceDataLine line = (SourceDataLine) AudioSystem.getLine(info)) {
                line.open(format);
                line.start();

                byte[] buffer = new byte[4096];
                int bytesRead;
                while ((bytesRead = audioStream.read(buffer)) != -1) {
                    line.write(buffer, 0, bytesRead);
                }

                line.drain();
                line.stop();
            }
        }
    }

    private void updateQueueStateInUI(AudioCommand command, boolean isRunning) {
        if (!isRunning) {
            SwingUtilities.invokeLater(() -> view.removeCommandFromQueueView(command, false));
        } else {
            SwingUtilities.invokeLater(() -> view.updateCommandState(command.getIdentifier(), true));
        }
    }

}
