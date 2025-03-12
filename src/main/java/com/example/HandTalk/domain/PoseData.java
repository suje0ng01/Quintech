package com.example.HandTalk.domain;


import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
@Table(name = "pose_data")
public class PoseData {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;


    private String keypointType;


    @Column(columnDefinition = "TEXT") //json text로 저장
    private String keyPoints; //손의 좌표
    private Double accuracy;


    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "practice_log_id")
    private PracticeLog practiceLog;

    // ✅ JSON 변환 메서드 추가
    private static final ObjectMapper objectMapper = new ObjectMapper();

    public void setKeyPoints(Object keyPoints) {
        try {
            this.keyPoints = objectMapper.writeValueAsString(keyPoints);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Failed to convert keypoints to JSON", e);
        }
    }

    public Object getKeypoints() {
        try {
            return objectMapper.readValue(this.keyPoints, Object.class);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Failed to convert JSON to keypoints", e);
        }
    }


}
