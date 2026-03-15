package com.example.demo.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/**
 * NAICS (North American Industry Classification System) code entity.
 * Codes are stored as VARCHAR to preserve meaningful leading zeros.
 * Data source: US Census Bureau, 2022 NAICS revision (public domain).
 */
@Entity
@Table(name = "naics_code")
public class NaicsCode {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 6)
    private String code;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false)
    private Integer level;

    protected NaicsCode() {
    }

    public NaicsCode(String code, String title, Integer level) {
        this.code = code;
        this.title = title;
        this.level = level;
    }

    public Long getId() {
        return id;
    }

    public String getCode() {
        return code;
    }

    public String getTitle() {
        return title;
    }

    public Integer getLevel() {
        return level;
    }
}
