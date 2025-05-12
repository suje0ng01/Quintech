package com.example.HandTalk.util;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.ContextRefreshedEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

import java.io.InputStream;
import java.util.*;

@Slf4j
@Getter
@Component
public class WordTopicLoader {

    private final Map<String, Integer> topicToChapterCount = new HashMap<>();
    private final Map<String, List<String>> topicToWords = new HashMap<>();
    private boolean initialized = false;

    @EventListener(ContextRefreshedEvent.class)
    public void loadOnStartup() {
        log.info("🔁 Application context 초기화 완료 → 단어 데이터 로딩 시도");
        load();
    }

    public synchronized void load() {
        try (InputStream inputStream = getClass().getClassLoader().getResourceAsStream("data/word_categories.json")) {
            if (inputStream == null) {
                throw new IllegalStateException("❌ JSON 파일 없음: data/word_categories.json");
            }

            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode root = objectMapper.readTree(inputStream);
            JsonNode categories = root.get("categories");

            if (categories == null || !categories.isArray()) {
                throw new IllegalStateException("❗ categories 항목 누락 또는 비정상");
            }

            topicToWords.clear();
            topicToChapterCount.clear();

            for (JsonNode category : categories) {
                String topic = category.get("topic").asText();
                List<String> words = new ArrayList<>();
                for (JsonNode word : category.get("words")) {
                    words.add(word.asText());
                }
                topicToWords.put(topic, words);
                topicToChapterCount.put(topic, words.size());
            }

            initialized = true;
            log.info("✅ 총 {}개 topic 로딩 완료: {}", topicToWords.size(), topicToWords.keySet());

        } catch (Exception e) {
            initialized = false;
            log.error("🔥 JSON 로딩 실패", e);
        }
    }

    public void ensureInitialized() {
        if (!initialized) {
            log.warn("⚠️ 데이터 미초기화 상태 → 재시도");
            load();
        }
    }

    public List<String> getWordsByTopic(String topic) {
        ensureInitialized();
        return topicToWords.getOrDefault(topic.trim(), Collections.emptyList());
    }
}
