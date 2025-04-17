package com.example.HandTalk.util;

import com.example.HandTalk.domain.ContentType;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;



@Component
public class FirebaseImageMapper {


    private static final Map<String, String> imageMap = new HashMap<>();


    static {

        imageMap.put("ㄱ", "https://firebase.com/images/consonant/ㄱ.png");
        imageMap.put("ㄴ", "https://firebase.com/images/consonant/ㄴ.png");
        imageMap.put("ㄷ", "https://firebase.com/images/consonant/ㄷ.png");
        imageMap.put("ㄹ", "https://firebase.com/images/consonant/ㄹ.png");
        imageMap.put("ㅁ", "https://firebase.com/images/consonant/ㅁ.png");
        imageMap.put("ㅂ", "https://firebase.com/images/consonant/ㅂ.png");
        imageMap.put("ㅅ", "https://firebase.com/images/consonant/ㅅ.png");
        imageMap.put("ㅇ", "https://firebase.com/images/consonant/ㅇ.png");
        imageMap.put("ㅈ", "https://firebase.com/images/consonant/ㅈ.png");
        imageMap.put("ㅊ", "https://firebase.com/images/consonant/ㅊ.png");
        imageMap.put("ㅋ", "https://firebase.com/images/consonant/ㅋ.png");
        imageMap.put("ㅌ", "https://firebase.com/images/consonant/ㅌ.png");
        imageMap.put("ㅍ", "https://firebase.com/images/consonant/ㅍ.png");
        imageMap.put("ㅎ", "https://firebase.com/images/consonant/ㅎ.png");

        // 모음 이미지
        imageMap.put("ㅏ", "https://firebase.com/images/vowel/ㅏ.png");
        imageMap.put("ㅑ", "https://firebase.com/images/vowel/ㅑ.png");
        imageMap.put("ㅓ", "https://firebase.com/images/vowel/ㅓ.png");
        imageMap.put("ㅕ", "https://firebase.com/images/vowel/ㅕ.png");
        imageMap.put("ㅗ", "https://firebase.com/images/vowel/ㅗ.png");
        imageMap.put("ㅛ", "https://firebase.com/images/vowel/ㅛ.png");
        imageMap.put("ㅜ", "https://firebase.com/images/vowel/ㅜ.png");
        imageMap.put("ㅠ", "https://firebase.com/images/vowel/ㅠ.png");
        imageMap.put("ㅡ", "https://firebase.com/images/vowel/ㅡ.png");
        imageMap.put("ㅣ", "https://firebase.com/images/vowel/ㅣ.png");
        imageMap.put("ㅐ", "https://firebase.com/images/vowel/ㅐ.png");
        imageMap.put("ㅔ", "https://firebase.com/images/vowel/ㅔ.png");
        imageMap.put("ㅚ", "https://firebase.com/images/vowel/ㅚ.png");
        imageMap.put("ㅟ", "https://firebase.com/images/vowel/ㅟ.png");
        imageMap.put("ㅢ", "https://firebase.com/images/vowel/ㅢ.png");

            // ✅ 동식물
            imageMap.put("문어", "https://firebase.com/images/word/문어.png");
            imageMap.put("토끼", "https://firebase.com/images/word/토끼.png");
            imageMap.put("뱀", "https://firebase.com/images/word/뱀.png");
            imageMap.put("소", "https://firebase.com/images/word/소.png");
            imageMap.put("늑대", "https://firebase.com/images/word/늑대.png");
            imageMap.put("잠자리", "https://firebase.com/images/word/잠자리.png");
            imageMap.put("새", "https://firebase.com/images/word/새.png");
            imageMap.put("나비", "https://firebase.com/images/word/나비.png");
            imageMap.put("강아지", "https://firebase.com/images/word/강아지.png");
            imageMap.put("오리", "https://firebase.com/images/word/오리.png");

            // ✅ 인간
            imageMap.put("엉뚱하다", "https://firebase.com/images/word/엉뚱하다.png");
            imageMap.put("신나다", "https://firebase.com/images/word/신나다.png");
            imageMap.put("얼굴,안면", "https://firebase.com/images/word/얼굴,안면.png");
            imageMap.put("보다", "https://firebase.com/images/word/보다.png");
            imageMap.put("예쁘다(곱다)", "https://firebase.com/images/word/예쁘다(곱다).png");
            imageMap.put("머리(뇌,두뇌)", "https://firebase.com/images/word/머리(뇌,두뇌).png");
            imageMap.put("부끄럽다", "https://firebase.com/images/word/부끄럽다.png");
            imageMap.put("솔직하다", "https://firebase.com/images/word/솔직하다.png");
            imageMap.put("울다", "https://firebase.com/images/word/울다.png");
            imageMap.put("못생기다", "https://firebase.com/images/word/못생기다.png");

            // ✅ 삶
            imageMap.put("깨다", "https://firebase.com/images/word/깨다.png");
            imageMap.put("두통", "https://firebase.com/images/word/두통.png");
            imageMap.put("저혈압", "https://firebase.com/images/word/저혈압.png");
            imageMap.put("닦다", "https://firebase.com/images/word/닦다.png");
            imageMap.put("면도", "https://firebase.com/images/word/면도.png");
            imageMap.put("반창고", "https://firebase.com/images/word/반창고.png");
            imageMap.put("노래", "https://firebase.com/images/word/노래.png");
            imageMap.put("낫다", "https://firebase.com/images/word/낫다.png");
            imageMap.put("살다,삶", "https://firebase.com/images/word/살다,삶.png");
            imageMap.put("화장", "https://firebase.com/images/word/화장.png");
            imageMap.put("바쁘다", "https://firebase.com/images/word/바쁘다.png");

            // ✅ 식생활
            imageMap.put("맥주", "https://firebase.com/images/word/맥주.png");
            imageMap.put("빵", "https://firebase.com/images/word/빵.png");
            imageMap.put("새우", "https://firebase.com/images/word/새우.png");
            imageMap.put("국수", "https://firebase.com/images/word/국수.png");
            imageMap.put("젓가락", "https://firebase.com/images/word/젓가락.png");
            imageMap.put("요리", "https://firebase.com/images/word/요리.png");
            imageMap.put("와인", "https://firebase.com/images/word/와인.png");
            imageMap.put("볶다", "https://firebase.com/images/word/볶다.png");
            imageMap.put("식당", "https://firebase.com/images/word/식당.png");
            imageMap.put("먹이다", "https://firebase.com/images/word/먹이다.png");
            imageMap.put("맵다", "https://firebase.com/images/word/맵다.png");

            // ✅ 주생활
            imageMap.put("(불빛을)켜다", "https://firebase.com/images/word/(불빛을)켜다.png");
            imageMap.put("칫솔", "https://firebase.com/images/word/칫솔.png");
            imageMap.put("엉망", "https://firebase.com/images/word/엉망.png");
            imageMap.put("집", "https://firebase.com/images/word/집.png");
            imageMap.put("화장실", "https://firebase.com/images/word/화장실.png");
            imageMap.put("식탁", "https://firebase.com/images/word/식탁.png");
            imageMap.put("벽", "https://firebase.com/images/word/벽.png");
            imageMap.put("지하", "https://firebase.com/images/word/지하.png");
            imageMap.put("시설", "https://firebase.com/images/word/시설.png");
            imageMap.put("빌딩", "https://firebase.com/images/word/빌딩.png");

            // ✅ 사회생활
            imageMap.put("대화", "https://firebase.com/images/word/대화.png");
            imageMap.put("잔치", "https://firebase.com/images/word/잔치.png");
            imageMap.put("신호등", "https://firebase.com/images/word/신호등.png");
            imageMap.put("연락,연결", "https://firebase.com/images/word/연락,연결.png");
            imageMap.put("만나다", "https://firebase.com/images/word/만나다.png");
            imageMap.put("수어", "https://firebase.com/images/word/수어.png");
            imageMap.put("말씀", "https://firebase.com/images/word/말씀.png");
            imageMap.put("휴대전화", "https://firebase.com/images/word/휴대전화.png");
            imageMap.put("하차", "https://firebase.com/images/word/하차.png");
            imageMap.put("승강기(엘레베이터)", "https://firebase.com/images/word/승강기(엘레베이터).png");

            // ✅ 문화
            imageMap.put("발레", "https://firebase.com/images/word/발레.png");
            imageMap.put("피아노", "https://firebase.com/images/word/피아노.png");
            imageMap.put("첼로", "https://firebase.com/images/word/첼로.png");
            imageMap.put("춤,무용", "https://firebase.com/images/word/춤,무용.png");
            imageMap.put("바이올린", "https://firebase.com/images/word/바이올린.png");
            imageMap.put("관람", "https://firebase.com/images/word/관람.png");
            imageMap.put("서예", "https://firebase.com/images/word/서예.png");
            imageMap.put("하모니카", "https://firebase.com/images/word/하모니카.png");
            imageMap.put("사진,찍다", "https://firebase.com/images/word/사진,찍다.png");
            imageMap.put("화상,영화", "https://firebase.com/images/word/화상,영화.png");

            // ✅ 개념
            imageMap.put("토요일", "https://firebase.com/images/word/토요일.png");
            imageMap.put("높이", "https://firebase.com/images/word/높이.png");
            imageMap.put("십,열", "https://firebase.com/images/word/십,열.png");
            imageMap.put("하나,한번", "https://firebase.com/images/word/하나,한번.png");
            imageMap.put("년,해", "https://firebase.com/images/word/년,해.png");
            imageMap.put("그녀", "https://firebase.com/images/word/그녀.png");
            imageMap.put("그", "https://firebase.com/images/word/그.png");
            imageMap.put("일등,최고,으뜸", "https://firebase.com/images/word/일등,최고,으뜸.png");
            imageMap.put("높다", "https://firebase.com/images/word/높다.png");
            imageMap.put("밝히다", "https://firebase.com/images/word/밝히다.png");

            // ✅ 기타
            imageMap.put("신문", "https://firebase.com/images/word/신문.png");
            imageMap.put("전과", "https://firebase.com/images/word/전과.png");
            imageMap.put("등대", "https://firebase.com/images/word/등대.png");
            imageMap.put("근본,기본", "https://firebase.com/images/word/근본,기본.png");
            imageMap.put("날리다", "https://firebase.com/images/word/날리다.png");
            imageMap.put("토하다, 게우다", "https://firebase.com/images/word/토하다,게우다.png");
            imageMap.put("오열", "https://firebase.com/images/word/오열.png");
            imageMap.put("찾다", "https://firebase.com/images/word/찾다.png");
            imageMap.put("끊어지다", "https://firebase.com/images/word/끊어지다.png");

            // ✅ 경제생활
            imageMap.put("빵집", "https://firebase.com/images/word/빵집.png");
            imageMap.put("재산", "https://firebase.com/images/word/재산.png");
            imageMap.put("환전", "https://firebase.com/images/word/환전.png");
            imageMap.put("달러", "https://firebase.com/images/word/달러.png");
            imageMap.put("저축,예금", "https://firebase.com/images/word/저축,예금.png");
            imageMap.put("밭", "https://firebase.com/images/word/밭.png");
            imageMap.put("주식", "https://firebase.com/images/word/주식.png");
            imageMap.put("선택,뽑다", "https://firebase.com/images/word/선택,뽑다.png");
            imageMap.put("주유소", "https://firebase.com/images/word/주유소.png");
            imageMap.put("공장,사업", "https://firebase.com/images/word/공장,사업.png");
            imageMap.put("집값", "https://firebase.com/images/word/집값.png");
        }




    public String getImageUrl(ContentType contentType, String key) {
        return imageMap.getOrDefault(key, null);
    }


    }

