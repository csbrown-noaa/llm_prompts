# LLM Prompt Template

**Objective:** This template provides a structured format for creating detailed and effective prompts for Large Language Models (LLMs). Its purpose is to ensure that all necessary components are considered, leading to more accurate, relevant, and well-formatted responses.

---

### **1. ⟨⟨Role and Goal⟩⟩**

* **Persona:** `[Specify the persona the LLM should adopt. Be descriptive. For example, "You are a senior marketing analyst," "You are a helpful and empathetic customer service representative," or "You are a witty and creative copywriter specializing in social media content."]`
* **Primary Objective:** `[State the single, most important goal the LLM should achieve with its response. For example, "Your primary objective is to analyze the provided customer feedback to identify the top three recurring issues," or "Your main goal is to generate three distinct subject lines for an email marketing campaign."]`

---

### **2. ⟨⟨Task and Execution⟩⟩**

* **Core Task(s):** `[Provide a clear, step-by-step description of what the LLM needs to do. Use action verbs. For example:
    1.  Read and comprehend the following user query.
    2.  Identify the user's core need.
    3.  Generate a comprehensive and accurate response that directly addresses that need.
    4.  Format the response according to the specified output format.]`
* **Keywords/Key Concepts:** `[List any specific keywords, phrases, or concepts that the LLM must include or focus on in its response. For example, "Ensure the response includes the terms 'synergy,' 'scalability,' and 'return on investment'."]`
* **Success Criteria:** `[Define what a successful completion of the task looks like. This helps the LLM understand the target. For example, "A successful response will be one that a non-technical audience can easily understand," or "Success is measured by the directness and accuracy of the answer, citing at least two sources from the provided context."]`

---

### **3. ⟨⟨Context⟩⟩**

* **Background Information:** `[Provide any relevant background information the LLM needs to understand the task. This could include project goals, previous conversations, or general context. For example, "This task is part of a larger project to overhaul our company's FAQ page. The target audience is new customers who have just purchased our software."]`
* **Input Data/Source Material:** `[Insert the specific text, data, or information that the LLM needs to work with here. For example, "[PASTE CUSTOMER REVIEW TEXT HERE]," or "[BELOW IS THE DRAFT ARTICLE FOR SUMMARY]," or "Analyze the following data set: [DATASET]"]`
* **Audience:** `[Describe the intended audience for the LLM's output. For example, "The audience is a group of senior executives who are short on time and need a high-level summary," or "The audience consists of software developers who require technical accuracy and code examples."]`

---

### **4. ⟨⟨Constraints and Rules⟩⟩**

* **Tone and Style:** `[Specify the desired tone and writing style. For example, "The tone should be formal, professional, and confident," or "Adopt a friendly, encouraging, and slightly humorous tone."]`
* **What to Avoid:** `[Clearly state any topics, phrases, or actions the LLM should avoid. For example, "Do not use technical jargon," "Avoid making any promises or guarantees," or "Do not generate any content that could be interpreted as financial advice."]`
* **Scope:** `[Define the boundaries of the task. For example, "Focus only on the information provided in the source material," or "Do not provide opinions or interpretations unless explicitly asked."]`
* **Word/Character Count:** `[If applicable, specify any length constraints. For example, "The response should be no more than 250 words," or "Each headline should be under 80 characters."]`

---

### **5. ⟨⟨Output Format⟩⟩**

* **Structure:** `[Describe the desired structure and format of the output. Be very specific. For example, "The output should be a JSON object with the following keys: 'summary', 'key_takeaways' (as a bulleted list), and 'sentiment_score'," or "Please format the response as a professional email, including a subject line, salutation, body, and closing."]`
* **Examples of Desired Output (Few-Shot Prompting):** `[Provide one or two high-quality examples of the desired output. This is one of the most effective ways to guide the LLM.
    * **Example 1:**
        * **Input:** [Sample Input 1]
        * **Output:** [Ideal Output for Sample 1]
    * **Example 2:**
        * **Input:** [Sample Input 2]
        * **Output:** [Ideal Output for Sample 2]]`

---
### **How to Use This Template**

1.  **Copy and Paste:** Start your prompt engineering process by copying this entire template.
2.  **Fill in the Blanks:** Go through each section and fill in the \`[bracketed]\` placeholders with the specifics of your task.
3.  **Be Specific and Clear:** The more precise and unambiguous your instructions, the better the LLM's output will be.
4.  **Iterate and Refine:** If the initial results are not perfect, review your filled-in template and identify areas for improvement. Adjust the context, constraints, or examples to further guide the model.
