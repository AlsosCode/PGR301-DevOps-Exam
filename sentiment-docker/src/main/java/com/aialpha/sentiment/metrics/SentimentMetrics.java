package com.aialpha.sentiment.metrics;

import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.Timer;
import io.micrometer.core.instrument.DistributionSummary;
import org.springframework.stereotype.Component;

import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

@Component
public class SentimentMetrics {

    private final MeterRegistry meterRegistry;
    private final AtomicInteger companiesDetectedCount;

    // Constructor injection of MeterRegistry
    public SentimentMetrics(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;

        // Initialize Gauge for tracking companies detected in last analysis
        this.companiesDetectedCount = new AtomicInteger(0);
        meterRegistry.gauge("sentiment.companies.detected",
            companiesDetectedCount);
    }

    /**
     * Example implementation: Counter for sentiment analysis requests
     * This counter tracks the total number of sentiment analyses by sentiment type and company
     */
    public void recordAnalysis(String sentiment, String company) {
        Counter.builder("sentiment.analysis.total")
                .tag("sentiment", sentiment)
                .tag("company", company)
                .description("Total number of sentiment analysis requests")
                .register(meterRegistry)
                .increment();
    }

    /**
     * Timer metric: Tracks AWS Bedrock API response time
     * Measures duration of operations with clear start and stop
     */
    public void recordDuration(long milliseconds, String company, String model) {
        Timer.builder("sentiment.bedrock.duration")
                .tag("company", company)
                .tag("model", model)
                .description("AWS Bedrock API response time in milliseconds")
                .register(meterRegistry)
                .record(milliseconds, TimeUnit.MILLISECONDS);
    }

    /**
     * Gauge metric: Tracks number of companies detected in last analysis
     * Represents a value that can increase or decrease over time
     */
    public void recordCompaniesDetected(int count) {
        companiesDetectedCount.set(count);
    }

    /**
     * DistributionSummary metric: Analyzes distribution of confidence scores
     * Shows statistical distribution of values between 0.0 and 1.0
     */
    public void recordConfidence(double confidence, String sentiment, String company) {
        DistributionSummary.builder("sentiment.confidence.score")
                .tag("sentiment", sentiment)
                .tag("company", company)
                .description("Distribution of confidence scores for sentiment analysis")
                .baseUnit("score")
                .register(meterRegistry)
                .record(confidence);
    }
}
