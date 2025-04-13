package com.example.HandTalk.util;

import com.example.HandTalk.domain.ContentType;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

@Component
public class FirebaseVideoMapper {

    private static final Map<String, String> videoMap = new HashMap<>();

    static {
        // ✅ 자음/모음 예시
        videoMap.put("consonant", "https://firebase.com/videos/consonant/ㄱ.mp4");
        videoMap.put("vowel", "https://firebase.com/videos/vowel/ㅏ.mp4");

        // ✅ 동식물
        videoMap.put("문어", "https://firebase.com/videos/word/문어.mp4");
        videoMap.put("토끼", "https://firebase.com/videos/word/토끼.mp4");
        videoMap.put("뱀", "https://firebase.com/videos/word/뱀.mp4");
        videoMap.put("소", "https://firebase.com/videos/word/소.mp4");
        videoMap.put("늑대", "https://firebase.com/videos/word/늑대.mp4");
        videoMap.put("잠자리", "https://firebase.com/videos/word/잠자리.mp4");
        videoMap.put("새", "https://firebase.com/videos/word/새.mp4");
        videoMap.put("나비", "https://firebase.com/videos/word/나비.mp4");
        videoMap.put("강아지", "https://firebase.com/videos/word/강아지.mp4");
        videoMap.put("오리", "https://firebase.com/videos/word/오리.mp4");

        // ✅ 인간
        videoMap.put("엉뚱하다", "https://firebase.com/videos/word/엉뚱하다.mp4");
        videoMap.put("신나다", "https://firebase.com/videos/word/신나다.mp4");
        videoMap.put("얼굴, 안면", "https://firebase.com/videos/word/얼굴, 안면.mp4");
        videoMap.put("보다", "https://firebase.com/videos/word/보다.mp4");
        videoMap.put("예쁘다(곱다)", "https://firebase.com/videos/word/예쁘다(곱다).mp4");
        videoMap.put("머리(뇌,두뇌)", "https://firebase.com/videos/word/머리(뇌,두뇌).mp4");
        videoMap.put("부끄럽다", "https://firebase.com/videos/word/부끄럽다.mp4");
        videoMap.put("솔직하다", "https://firebase.com/videos/word/솔직하다.mp4");
        videoMap.put("울다", "https://firebase.com/videos/word/울다.mp4");
        videoMap.put("못생기다", "https://firebase.com/videos/word/못생기다.mp4");

        // ✅ 삶
        videoMap.put("깨다", "https://firebase.com/videos/word/깨다.mp4");
        videoMap.put("두통", "https://firebase.com/videos/word/두통.mp4");
        videoMap.put("저혈압", "https://firebase.com/videos/word/저혈압.mp4");
        videoMap.put("닦다", "https://firebase.com/videos/word/닦다.mp4");
        videoMap.put("면도", "https://firebase.com/videos/word/면도.mp4");
        videoMap.put("반창고", "https://firebase.com/videos/word/반창고.mp4");
        videoMap.put("노래", "https://firebase.com/videos/word/노래.mp4");
        videoMap.put("낫다", "https://firebase.com/videos/word/낫다.mp4");
        videoMap.put("살다, 삶", "https://firebase.com/videos/word/살다, 삶.mp4");
        videoMap.put("화장", "https://firebase.com/videos/word/화장.mp4");
        videoMap.put("바쁘다", "https://firebase.com/videos/word/바쁘다.mp4");
    }

    public String getVideoUrl(ContentType contentType, String key) {
        return videoMap.getOrDefault(key, null);
    }
}
