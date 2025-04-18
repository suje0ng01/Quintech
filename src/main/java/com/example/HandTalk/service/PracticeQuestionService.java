package com.example.HandTalk.service;

import com.example.HandTalk.domain.ContentType;
import com.example.HandTalk.dto.PracticeQuestionDto;
import com.example.HandTalk.util.WordTopicLoader;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PracticeQuestionService {

    private final WordTopicLoader wordTopicLoader;

    public List<PracticeQuestionDto> getConsonantQuestions() {
        List<String> consonants = List.of("ㄱ", "ㄴ", "ㄷ", "ㄹ", "ㅁ", "ㅂ", "ㅅ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ");
        return consonants.stream()
                .map(c -> new PracticeQuestionDto(ContentType.CONSONANT, c))
                .collect(Collectors.toList());
    }

    public List<PracticeQuestionDto> getVowelQuestions() {
        List<String> vowels = List.of("ㅏ", "ㅑ", "ㅓ", "ㅕ", "ㅗ", "ㅛ", "ㅜ", "ㅠ", "ㅡ", "ㅣ", "ㅐ", "ㅔ", "ㅚ", "ㅟ", "ㅢ");
        return vowels.stream()
                .map(v -> new PracticeQuestionDto(ContentType.VOWEL, v))
                .collect(Collectors.toList());
    }

    public List<PracticeQuestionDto> getWordQuestions(String topic) {
        List<String> words = wordTopicLoader.getWordsByTopic(topic);
        return words.stream()
                .map(word -> new PracticeQuestionDto(ContentType.WORD, word))
                .collect(Collectors.toList());
    }
}
