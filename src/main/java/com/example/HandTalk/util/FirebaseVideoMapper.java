package com.example.HandTalk.util;

import com.example.HandTalk.domain.ContentType;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

@Component
public class FirebaseVideoMapper {

    private static final Map<String, String> videoMap = new HashMap<>();

    static {


        videoMap.put("ㄱ", "https://firebase.com/videos/consonant/ㄱ.mp4");
        videoMap.put("ㄴ", "https://firebase.com/videos/consonant/ㄴ.mp4");
        videoMap.put("ㄷ", "https://firebase.com/videos/consonant/ㄷ.mp4");
        videoMap.put("ㄹ", "https://firebase.com/videos/consonant/ㄹ.mp4");
        videoMap.put("ㅁ", "https://firebase.com/videos/consonant/ㅁ.mp4");
        videoMap.put("ㅂ", "https://firebase.com/videos/consonant/ㅂ.mp4");
        videoMap.put("ㅅ", "https://firebase.com/videos/consonant/ㅅ.mp4");
        videoMap.put("ㅇ", "https://firebase.com/videos/consonant/ㅇ.mp4");
        videoMap.put("ㅈ", "https://firebase.com/videos/consonant/ㅈ.mp4");
        videoMap.put("ㅊ", "https://firebase.com/videos/consonant/ㅊ.mp4");
        videoMap.put("ㅋ", "https://firebase.com/videos/consonant/ㅋ.mp4");
        videoMap.put("ㅌ", "https://firebase.com/videos/consonant/ㅌ.mp4");
        videoMap.put("ㅍ", "https://firebase.com/videos/consonant/ㅍ.mp4");
        videoMap.put("ㅎ", "https://firebase.com/videos/consonant/ㅎ.mp4");

        // ✅ 모음 개별 매핑
        videoMap.put("ㅏ", "https://firebase.com/videos/vowel/ㅏ.mp4");
        videoMap.put("ㅑ", "https://firebase.com/videos/vowel/ㅑ.mp4");
        videoMap.put("ㅓ", "https://firebase.com/videos/vowel/ㅓ.mp4");
        videoMap.put("ㅕ", "https://firebase.com/videos/vowel/ㅕ.mp4");
        videoMap.put("ㅗ", "https://firebase.com/videos/vowel/ㅗ.mp4");
        videoMap.put("ㅛ", "https://firebase.com/videos/vowel/ㅛ.mp4");
        videoMap.put("ㅜ", "https://firebase.com/videos/vowel/ㅜ.mp4");
        videoMap.put("ㅠ", "https://firebase.com/videos/vowel/ㅠ.mp4");
        videoMap.put("ㅡ", "https://firebase.com/videos/vowel/ㅡ.mp4");
        videoMap.put("ㅐ", "https://firebase.com/videos/vowel/ㅐ.mp4");
        videoMap.put("ㅚ", "https://firebase.com/videos/vowel/ㅚ.mp4");
        videoMap.put("ㅟ", "https://firebase.com/videos/vowel/ㅟ.mp4");
        videoMap.put("ㅢ", "https://firebase.com/videos/vowel/ㅢ.mp4");
        videoMap.put("ㅣ", "https://firebase.com/videos/vowel/ㅣ.mp4");
        videoMap.put("ㅔ", "https://firebase.com/videos/vowel/ㅔ.mp4");


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
        videoMap.put("얼굴,안면", "https://firebase.com/videos/word/얼굴,안면.mp4");
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
        videoMap.put("살다,삶", "https://firebase.com/videos/word/살다,삶.mp4");
        videoMap.put("화장", "https://firebase.com/videos/word/화장.mp4");
        videoMap.put("바쁘다", "https://firebase.com/videos/word/바쁘다.mp4");

        // ✅ 식생활
        videoMap.put("맥주", "https://firebase.com/videos/word/맥주.mp4");
        videoMap.put("빵", "https://firebase.com/videos/word/빵.mp4");
        videoMap.put("새우", "https://firebase.com/videos/word/새우.mp4");
        videoMap.put("국수", "https://firebase.com/videos/word/국수.mp4");
        videoMap.put("젓가락", "https://firebase.com/videos/word/젓가락.mp4");
        videoMap.put("요리", "https://firebase.com/videos/word/요리.mp4");
        videoMap.put("와인", "https://firebase.com/videos/word/와인.mp4");
        videoMap.put("볶다", "https://firebase.com/videos/word/볶다.mp4");
        videoMap.put("식당", "https://firebase.com/videos/word/식당.mp4");
        videoMap.put("먹이다", "https://firebase.com/videos/word/먹이다.mp4");
        videoMap.put("맵다", "https://firebase.com/videos/word/맵다.mp4");

// ✅ 주생활
        videoMap.put("(불빛을)켜다", "https://firebase.com/videos/word/(불빛을)켜다.mp4");
        videoMap.put("칫솔", "https://firebase.com/videos/word/칫솔.mp4");
        videoMap.put("엉망", "https://firebase.com/videos/word/엉망.mp4");
        videoMap.put("집", "https://firebase.com/videos/word/집.mp4");
        videoMap.put("화장실", "https://firebase.com/videos/word/화장실.mp4");
        videoMap.put("식탁", "https://firebase.com/videos/word/식탁.mp4");
        videoMap.put("벽", "https://firebase.com/videos/word/벽.mp4");
        videoMap.put("지하", "https://firebase.com/videos/word/지하.mp4");
        videoMap.put("시설", "https://firebase.com/videos/word/시설.mp4");
        videoMap.put("빌딩", "https://firebase.com/videos/word/빌딩.mp4");

// ✅ 사회생활
        videoMap.put("대화", "https://firebase.com/videos/word/대화.mp4");
        videoMap.put("잔치", "https://firebase.com/videos/word/잔치.mp4");
        videoMap.put("신호등", "https://firebase.com/videos/word/신호등.mp4");
        videoMap.put("연락,연결", "https://firebase.com/videos/word/연락,연결.mp4");
        videoMap.put("만나다", "https://firebase.com/videos/word/만나다.mp4");
        videoMap.put("수어", "https://firebase.com/videos/word/수어.mp4");
        videoMap.put("말씀", "https://firebase.com/videos/word/말씀.mp4");
        videoMap.put("휴대전화", "https://firebase.com/videos/word/휴대전화.mp4");
        videoMap.put("하차", "https://firebase.com/videos/word/하차.mp4");
        videoMap.put("승강기(엘레베이터)", "https://firebase.com/videos/word/승강기(엘레베이터).mp4");

// ✅ 문화
        videoMap.put("발레", "https://firebase.com/videos/word/발레.mp4");
        videoMap.put("피아노", "https://firebase.com/videos/word/피아노.mp4");
        videoMap.put("첼로", "https://firebase.com/videos/word/첼로.mp4");
        videoMap.put("춤,무용", "https://firebase.com/videos/word/춤,무용.mp4");
        videoMap.put("바이올린", "https://firebase.com/videos/word/바이올린.mp4");
        videoMap.put("관람", "https://firebase.com/videos/word/관람.mp4");
        videoMap.put("서예", "https://firebase.com/videos/word/서예.mp4");
        videoMap.put("하모니카", "https://firebase.com/videos/word/하모니카.mp4");
        videoMap.put("사진,찍다", "https://firebase.com/videos/word/사진,찍다.mp4");
        videoMap.put("화상,영화", "https://firebase.com/videos/word/화상,영화.mp4");

// ✅ 개념
        videoMap.put("토요일", "https://firebase.com/videos/word/토요일.mp4");
        videoMap.put("높이", "https://firebase.com/videos/word/높이.mp4");
        videoMap.put("십,열", "https://firebase.com/videos/word/십,열.mp4");
        videoMap.put("하나,한번", "https://firebase.com/videos/word/하나,한번.mp4");
        videoMap.put("년,해", "https://firebase.com/videos/word/년,해.mp4");
        videoMap.put("그녀", "https://firebase.com/videos/word/그녀.mp4");
        videoMap.put("그", "https://firebase.com/videos/word/그.mp4");
        videoMap.put("일등,최고,으뜸", "https://firebase.com/videos/word/일등,최고,으뜸.mp4");
        videoMap.put("높다", "https://firebase.com/videos/word/높다.mp4");
        videoMap.put("밝히다", "https://firebase.com/videos/word/밝히다.mp4");

// ✅ 기타
        videoMap.put("신문", "https://firebase.com/videos/word/신문.mp4");
        videoMap.put("전과", "https://firebase.com/videos/word/전과.mp4");
        videoMap.put("등대", "https://firebase.com/videos/word/등대.mp4");
        videoMap.put("근본,기본", "https://firebase.com/videos/word/근본,기본.mp4");
        videoMap.put("날리다", "https://firebase.com/videos/word/날리다.mp4");
        videoMap.put("토하다, 게우다", "https://firebase.com/videos/word/토하다,게우다.mp4");
        videoMap.put("오열", "https://firebase.com/videos/word/오열.mp4");
        videoMap.put("찾다", "https://firebase.com/videos/word/찾다.mp4");
        videoMap.put("끊어지다", "https://firebase.com/videos/word/끊어지다.mp4");

// ✅ 경제생활
        videoMap.put("빵집", "https://firebase.com/videos/word/빵집.mp4");
        videoMap.put("재산", "https://firebase.com/videos/word/재산.mp4");
        videoMap.put("환전", "https://firebase.com/videos/word/환전.mp4");
        videoMap.put("달러", "https://firebase.com/videos/word/달러.mp4");
        videoMap.put("저축,예금", "https://firebase.com/videos/word/저축,예금.mp4");
        videoMap.put("밭", "https://firebase.com/videos/word/밭.mp4");
        videoMap.put("주식", "https://firebase.com/videos/word/주식.mp4");
        videoMap.put("선택,뽑다", "https://firebase.com/videos/word/선택,뽑다.mp4");
        videoMap.put("주유소", "https://firebase.com/videos/word/주유소.mp4");
        videoMap.put("공장,사업", "https://firebase.com/videos/word/공장,사업.mp4");
        videoMap.put("집값", "https://firebase.com/videos/word/집값.mp4");

    }

    public String getVideoUrl(ContentType contentType, String key) {
        return videoMap.getOrDefault(key, null);
    }
}
