package com.example.HandTalk.util;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.annotation.PostConstruct;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

@Slf4j
@Component
public class WordTopicLoader {

    @Getter
    private final Map<String, Integer> topicToChapterCount = new HashMap<>();

    @PostConstruct
    public void init() {
        try (InputStream inputStream = getClass().getClassLoader().getResourceAsStream("data/word_categories.json")) {
            if (inputStream == null) {
                throw new IllegalArgumentException("JSON 파일을 찾을 수 없습니다: data/word_categories.json");
            }

            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode rootNode = objectMapper.readTree(inputStream);
            JsonNode categories = rootNode.get("categories");

            if (categories != null && categories.isArray()) {
                for (JsonNode category : categories) {
                    JsonNode topicNode = category.get("topic");
                    JsonNode wordsNode = category.get("words");

                    if (topicNode != null && wordsNode != null && wordsNode.isArray()) {
                        String topic = topicNode.asText();
                        int wordCount = wordsNode.size(); // 단어 수 == 챕터 수
                        topicToChapterCount.put(topic, wordCount);
                    }
                }
                log.info("단어 카테고리 {}개 로딩 완료: {}", topicToChapterCount.size(), topicToChapterCount.keySet());
            } else {
                log.warn("categories 항목이 없거나 배열이 아닙니다.");
            }

        } catch (Exception e) {
            log.error("단어 JSON 로딩 실패", e);
        }
    }
}
