public interface E2EContactDetailsStep {
    E2EStepContent getContent(String jsonSettings, String source);
    void save(E2EStepContent stepContent);
}