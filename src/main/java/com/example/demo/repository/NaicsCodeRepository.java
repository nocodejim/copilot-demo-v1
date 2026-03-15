package com.example.demo.repository;

import com.example.demo.model.NaicsCode;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository for NAICS code lookups.
 */
@Repository
public interface NaicsCodeRepository extends JpaRepository<NaicsCode, Long> {

    Optional<NaicsCode> findByCode(String code);

    List<NaicsCode> findByLevel(Integer level);

    List<NaicsCode> findByTitleContainingIgnoreCase(String keyword);

    List<NaicsCode> findByCodeStartingWith(String prefix);
}
