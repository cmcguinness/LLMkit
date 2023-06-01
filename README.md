# LLMkit README
*A library for making it easy for Salesforce's OmniStudio to call GPT*

LLMkit is an Apex class that is callable from OmniStudio that provides machinery to call OpenAI's API.  The basic idea is that you define a "service" that includes the various prompts (which can have live data inserted into them) and parameters, and the OmniScript just has to call the service without concern for the specifics. The class supports not just "fully baked" services, but offers some tools to make it easy to build and debug your calls to OpenAI.

As an example of a service, you could have a "Recommend Life Insurance Policy" service which would run based upon demographic and financial planning information from the customer and return structured data about the recommended policy.

For instructions on how to install and use this tool, please read the [documentation](Documentation).

