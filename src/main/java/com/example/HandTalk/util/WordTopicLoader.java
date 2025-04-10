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
        try (InputStream inputStream = getClass().getResourceAsStream("/data/word_categories.json")) {
            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode rootNode = objectMapper.readTree(inputStream);
            JsonNode categories = rootNode.get("categories");

            if (categories != null && categories.isArray()) {
                for (JsonNode category : categories) {
                    String topic = category.get("topic").asText();
                    int chapterCount = category.get("words").size();
                    topicToChapterCount.put(topic, chapterCount);
                }
            }
        } catch (Exception e) {
            log.error("단어 JSON 로딩 실패", e);
        }
    }
}
