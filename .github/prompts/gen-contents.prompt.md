---
mode: 'agent'
---
Note: Ensure that there is exactly one blank line after each section title before the content (e.g., **Summary**\n\nYour text...).
Generate the content for chapter # specified in #folder:contents according to the following rules and actions below, keep the content in this order with the titles:

**Summary**

Do: Summarize up a subject of the content or the Subject if specified or regarding the whole content of the reference in #folder:src.

**Concepts Map**

Do: Create a Mermaid diagram in text format of the underlying content, identifying key concepts, keep their names short, breaking down these concepts and their interrelations from the given text of Chapter. Enhance it with named relationships and make use of subgraphs when possible.

**Key Concepts**

Do: Generate a list of key concepts and their meanings for underlying content. Use bullets with * for put the name of the concept in bold e.g.:
* **concept** concept description

**Quiz**

Do: Generate exactly ten multiple choice questions picking up a Subject of the underlying content if specified or regarding the whole content in #folder:src. Ensure there are exactly ten questions, no more and no less. Append next to the title a timestamp as YYYYMMDD_HH:MM:SS. For the choice questions options use a lowercase letter to identify each choice but prefixed with a checkbox in the format `- ` and do not prefix it with tab see below a example:
1. What is the primary focus of software design and architecture?
- a) Writing code quickly
- b) Achieving maintainable and scalable software
- c) Using the latest programming language
- d) Avoiding documentation
The correct answers with brief explanations shall be appended at the end of the Quiz.

**Challenge**

Generate a Challenge up a subject of the content if specified or regarding the whole content in #folder:src. The Challenge answer with brief explanations shall be appended at the end of the Challenge.
