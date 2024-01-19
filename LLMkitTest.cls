/**
 * LLMkitTest
 * 
 * This is the test class for LLMkit.cls
 * 
 * In addition to providing sufficient coverage for deploying into production,
 * which you do at your own risk; see the license in LLMkit.cls, it provides
 * a wealth of examples of how to call LLMkit.  Even if you're not calling it
 * from Apex, but OmniScript instead, it still might help explain exactly what
 * some of the options do.
 * 
 */

 @isTest
 public with sharing class LLMkitTest {

    /**
     * createArgs
     * 
     * Create a set of empty input, options, and output maps that we need for any call
     * into LLMkit.
     */
    static Map<String,Map<String,Object>>  createArgs() {
        Map<String,Map<String,Object>> args = new Map<String,Map<String,Object>>();
        args.put('input',new Map<String,Object>());
        args.put('output',new Map<String,Object>());
        args.put('options',new Map<String,Object>());
        return args;
    }

    //  -------------------------------------------------------------------------
    //  No such method error testing
    //  -------------------------------------------------------------------------
    @isTest
    static void text_bad_method() {
        LLMkit llmkit = new LLMkit();
        Map<String,Map<String,Object>> args = createArgs();

        llmkit.call('THIS DOES NOT EXIST', args);
        System.assert(args.get('output').containsKey('error'));
    }

    //  -------------------------------------------------------------------------
    //  "ping" method testing
    //  -------------------------------------------------------------------------

    /**
     * test_ping
     * 
     * Tests the callable method "ping".  Not much to it.
     * 
     */
    @isTest
    static void test_ping(){
        LLMkit llmkit = new LLMkit();
        Map<String,Map<String,Object>> args = createArgs();

        llmkit.call('ping', args);
        System.assert(args.get('output').containsKey('response'));
        String response = (String) (args.get('output').get('response'));
        System.assert(response == 'pong');
        
    }

    //  -------------------------------------------------------------------------
    //  "generate_template" method testing
    //  -------------------------------------------------------------------------

    /**
     * test_generate_template_good
     * 
     * Tests population of data into a working template via the generate_template method
     */

    @isTest
    static void test_generate_template_good() {
        LLMkit llmkit = new LLMkit();
        Map<String,Map<String,Object>> args = createArgs();
        Map<String,Object> options =args.get('options');
        Map<String,Object> input = args.get('input');

        options.put('template', 'I would like to buy widgets in the following colors and quantities:\n\nWhite: {{ Step1.selWhite }}\nBlack: {{ Step1.selBlack }}\nRed: {{ Step1.selRed }}\nBlue: {{ Step1.selBlue }}\nGreen: {{ Step1.selGreen }}\nCyan: {{ Step1.selCyan }}\nMagenta: {{ Step1.selMagenta }}\nYellow: {{ Step1.selYellow }}\n\nIs that allowed?\nUsers are {% for Name in Names %}{{ Name}} {% endfor %}');
        args.put('input', ((Map<String,Object>)JSON.deserializeUntyped('{\n\"Names\": [\n  \"Alice\", \"Bob\", \"Carl\"\n],\n  \"Step1\": {\n    \"selWhite\": \"1\",\n    \"selBlack\": \"0\",\n    \"selRed\": \"1\",\n    \"selBlue\": \"1\",\n    \"selGreen\": \"1\",\n    \"selCyan\": \"1\",\n    \"selMagenta\": \"0\",\n    \"selYellow\": \"1\"\n  }\n}')));
        System.debug('.test_generate_template_good args: ' + JSON.serialize(args));
        llmkit.call('generate_template',args);
        Map<String,Object> output = args.get('output');
        System.debug('.test_generate_template_good output: ' + JSON.serialize(output));

        String response = String.valueOf(args.get('output').get('response'));
        System.debug('.test_generate_template_good response: ' + response);

        String expected_response = 'I would like to buy widgets in the following colors and quantities:\n\nWhite: 1\nBlack: 0\nRed: 1\nBlue: 1\nGreen: 1\nCyan: 1\nMagenta: 0\nYellow: 1\n\nIs that allowed?\nUsers are Alice Bob Carl ';
        System.assert(response==expected_response);
    }

    /**
     * test_generate_template_logic
     * 
     * Make sure if with nested for logic works
     */
    @isTest
    static void test_generate_template_logic() {
        LLMkit llmkit = new LLMkit();
        Map<String,Map<String,Object>> args = createArgs();
        Map<String,Object> options =args.get('options');
        Map<String,Object> input = args.get('input');

        options.put('template', '{% if a %} a is non-zero {% endif %}{% if b %}bdata is {% for i in bdata %}{{ i }}, {% endfor %}{% endif %}');
        args.put('input', ((Map<String,Object>)JSON.deserializeUntyped('{"a": 0, "b": 1, "bdata": [ 10, 11, 12 ] }')));
        System.debug('.test_generate_template_logic args: ' + JSON.serialize(args));
        llmkit.call('generate_template',args);
        Map<String,Object> output = args.get('output');
        System.debug('.test_generate_template_logic output: ' + JSON.serialize(output));

        String response = String.valueOf(args.get('output').get('response'));
        System.debug('.test_generate_template_logic response: ' + response);

        String expected_response = 'bdata is 10, 11, 12, ';
        System.assert(response==expected_response);
    }


    /**
     * test_generate_tempalte_error
     * 
     * Tests what happens if you pass a static resource name that doesn't exist
     */
    @isTest
    static void test_generate_tempalte_error() {
        LLMkit llmkit = new LLMkit();
        Map<String,Map<String,Object>> args = createArgs();
        Map<String,Object> options =args.get('options');
        Map<String,Object> input = args.get('input');

        options.put('template', '@ThisStaticResourceDoesNotExist');
        args.put('input', ((Map<String,Object>)JSON.deserializeUntyped('{}')));
        System.debug('.test_generate_tempalte_error args: ' + JSON.serialize(args));
        llmkit.call('generate_template',args);
        Map<String,Object> output = args.get('output');
        System.debug('.test_generate_tempalte_error output: ' + JSON.serialize(output));

        String response = String.valueOf(args.get('output').get('error'));
        String expected_response = 'The template @ThisStaticResourceDoesNotExist was not found';
        System.assert(response==expected_response);
    }


    //  -------------------------------------------------------------------------
    //  "call_openai" method testing
    //  -------------------------------------------------------------------------
    
    /**
     * WARNING
     * 
     * Because tests are not allowed to make actual calls, while these tests
     * exercise the code, they do not and can not test how OpenAI would
     * actually respond to our calls.
     * 
     * We could use the HTTP mock interfaces to call back to us and try to implement 
     * a mock OpenAI, but that only garners a bit more coverage. So be aware that
     * you will want to do live testing outside of a Salesforce test class
     * as part of your due dilligance. 
     */

    /**
     *  callChatGPTtest
     * 
     *  Testing a ../chat/completion model like gpt-4
     */
    @isTest
    static void callChatGPTtest() {
        LLMkit llmkit = new LLMkit();
        Map<String,Map<String,Object>> args = createArgs();
        Map<String,Object> options =args.get('options');
        Map<String,Object> input = args.get('input');

        List<Map<String,Object>> history = new  List<Map<String,Object>>();

        options.put('user_template', 'I would like to buy widgets in the following colors and quantities:\n\n{% if Step1.selWhite %} White: {{ Step1.selWhite }}{% else %} {% endif %}\n{% if Step1.selBlack %} Black: {{ Step1.selBlack }} {% endif %}\n{% if Step1.selRed %} Red: {{ Step1.selRed }} {% endif %}\n{% if Step1.selBlue %} Blue: {{ Step1.selBlue }} {% endif %}\n{% if Step1.selGreen %} Green: {{ Step1.selGreen }} {% endif %}\n{% if Step1.selCyan %} Cyan: {{ Step1.selCyan }} {% endif %}\n{% if Step1.selMagenta %} Magenta: {{ Step1.selMagenta }} {% endif %}\n{% if Step1.selYellow %} Yellow: {{ Step1.selYellow }} {% endif %}\n\nIs that allowed?');
        options.put('system_template', '{# This is a comment #}\n\nYou are an order management specialist at a widget factory.  \nThere are 8 different types of widgets: \n\n* The primary colors: red, blue, and green\n* The secondary colors: yellow, magenta, and cyan\n* Two desaturated colors: black, and white.\n\nFor every cyan widget someone buys, they must also buy one more blue and one more green widget.\n\nFor every yellow widget someone buys, they must also buy an additional red and green widget.\n\nFor every magenta widget someone buys, they must also buy an additional red and a blue widget.\n\nThe widgets in red, blue, green, black, and white have no restrictions on them.\n\nThe required additional widgets are additive. Thus, if you buy two secondary colored widgets, \nyou have to buy the corresponding four primary colored widgets to meet the requirements.\n\nFor example, if you buy yellow and magenta, you will must but two reds, one green, and one blue in your order.\n\nYour job is to look at an order a customer wants to make and to verify that it follows the rules.\n\nThe way to do this is to look at each of the secondary colors, add up the required primary colors,\nand make sure the order has at least that many of each primary color.\n \nExplain your reasoning step by step.');
        options.put('model', 'gpt-4');
        options.put('temperature', '0.0');
        options.put('mock_response', 'THIS IS A MOCK RESPONSE');
        options.put('named_credential', 'OpenAI');
        options.put('history', history);
        options.put('text_history','true');

        args.put('input', ((Map<String,Object>)JSON.deserializeUntyped('{\n\"Names\": [\n  \"Alice\", \"Bob\", \"Carl\"\n],\n  \"Step1\": {\n    \"selWhite\": \"1\",\n    \"selBlack\": \"0\",\n    \"selRed\": \"1\",\n    \"selBlue\": \"1\",\n    \"selGreen\": \"1\",\n    \"selCyan\": \"1\",\n    \"selMagenta\": \"0\",\n    \"selYellow\": \"1\"\n  }\n}')));

        llmkit.call('call_openai', args);
        Map<String,Object> output = args.get('output');
        System.debug('.callChatGPTtest output: ' + JSON.serialize(output));

        String response = String.valueOf(args.get('output').get('response'));
        System.assert(response == 'THIS IS A MOCK RESPONSE');

        List<Object> back_history = (List<Object>) (args.get('output').get('history'));
        System.assert(back_history.size() == 2);

        String text_history = (String) output.get('history_text');

        System.assert(text_history.length() > 0);

    }

    /**
     * callGPTtest
     * 
     * Testing a /completion (no chat) model like text-divinci-003
     */
    @isTest
    static void callGPTtest() {
        LLMkit llmkit = new LLMkit();
        Map<String,Map<String,Object>> args = createArgs();
        Map<String,Object> options =args.get('options');
        Map<String,Object> input = args.get('input');

        options.put('prompt_template', 'I would like to buy widgets in the following colors and quantities:\n\n{% if Step1.selWhite %} White: {{ Step1.selWhite }}{% else %} {% endif %}\n{% if Step1.selBlack %} Black: {{ Step1.selBlack }} {% endif %}\n{% if Step1.selRed %} Red: {{ Step1.selRed }} {% endif %}\n{% if Step1.selBlue %} Blue: {{ Step1.selBlue }} {% endif %}\n{% if Step1.selGreen %} Green: {{ Step1.selGreen }} {% endif %}\n{% if Step1.selCyan %} Cyan: {{ Step1.selCyan }} {% endif %}\n{% if Step1.selMagenta %} Magenta: {{ Step1.selMagenta }} {% endif %}\n{% if Step1.selYellow %} Yellow: {{ Step1.selYellow }} {% endif %}\n\nIs that allowed?');
        options.put('model', 'text-davinci-002');
        options.put('temperature', '0.0');
        options.put('mock_response', 'THIS IS A MOCK RESPONSE');
        options.put('named_credential', 'OpenAI');

        args.put('input', ((Map<String,Object>)JSON.deserializeUntyped('{\n\"Names\": [\n  \"Alice\", \"Bob\", \"Carl\"\n],\n  \"Step1\": {\n    \"selWhite\": \"1\",\n    \"selBlack\": \"0\",\n    \"selRed\": \"1\",\n    \"selBlue\": \"1\",\n    \"selGreen\": \"1\",\n    \"selCyan\": \"1\",\n    \"selMagenta\": \"0\",\n    \"selYellow\": \"1\"\n  }\n}')));

        llmkit.call('call_openai', args);
        Map<String,Object> output = args.get('output');
        System.debug('.callGPTtest output: ' + JSON.serialize(output));

        String response = String.valueOf(args.get('output').get('response'));
        System.assert(response.equals('THIS IS A MOCK RESPONSE'));

    }

    /**
     * get_object_type
     * 
     * Returns the salesforce object type of a variable
     * 
     * Debugging function, taken from: https://ideas.salesforce.com/s/feed/0D58W000069LiQ8SAK
     */
    public static String get_object_type(Object obj) { 
        String result = 'DateTime'; 
        try { DateTime typeCheck = (DateTime)obj; } 
        catch(System.TypeException te) { 
            String message = te.getMessage().substringAfter('Invalid conversion from runtime type '); 
            result = message.substringBefore(' to Datetime'); 
        } 
        return result; 
    }

    /**
     * callGPTforJSONtest
     * 
     * Test of the json_response option
     */
    @isTest
    static void callGPTforJSONtest() {
        LLMkit llmkit = new LLMkit();
        Map<String,Map<String,Object>> args = createArgs();
        Map<String,Object> options =args.get('options');
        Map<String,Object> input = args.get('input');

        options.put('prompt_template', 'This really does not matter');
        options.put('model', 'text-davinci-002');
        options.put('temperature', '0.0');
        options.put('mock_response', '{\\"itworks\\": true}');
        options.put('json_response','true');
        options.put('max_tokens','1024');
        options.put('named_credential', 'OpenAI');

        args.put('input', ((Map<String,Object>)JSON.deserializeUntyped('{\n\"Names\": [\n  \"Alice\", \"Bob\", \"Carl\"\n],\n  \"Step1\": {\n    \"selWhite\": \"1\",\n    \"selBlack\": \"0\",\n    \"selRed\": \"1\",\n    \"selBlue\": \"1\",\n    \"selGreen\": \"1\",\n    \"selCyan\": \"1\",\n    \"selMagenta\": \"0\",\n    \"selYellow\": \"1\"\n  }\n}')));

        llmkit.call('call_openai', args);
        Map<String,Object> output = args.get('output');
        System.debug('callGPTforJSONtest output: ' + JSON.serialize(output));

        Object response = args.get('output').get('response');
        System.debug('callGPTforJSONtest response type: ' + get_object_type(response));
        System.assert(response instanceof Map<String,Object>);

    }

    /**
     * test_good_service
     * 
     * Test for a good openai_service name
     */
    @isTest
    static void test_good_service() {

        LLMkit llmkit = new LLMkit();
        Map<String,Map<String,Object>> args = createArgs();
        Map<String,Object> options =args.get('options');
        Map<String,Object> input = args.get('input');

        options.put('openai_service', '{\n\"prompt_template\": \"the precise contents here do not matter\",\n\"model\": \"text-davinci-002\",\n\"mock_response\": \"THIS IS A MOCK RESPONSE\",\n\"api_key\": \"sk-1234567890\"\n}');
        // options.put('openai_service', '@LLMkitTestService01');
        llmkit.call('call_openai', args);
        Map<String,Object> output = args.get('output');
        System.debug('.test_good_service output: ' + JSON.serialize(output));

        String response = String.valueOf(args.get('output').get('response'));
        System.assert(response == 'THIS IS A MOCK RESPONSE');

    }

    /**
     * test_bad_service
     * 
     * Test for a bad openai_service name
     */
    @isTest
    static void test_bad_service() {
        LLMkit llmkit = new LLMkit();
        Map<String,Map<String,Object>> args = createArgs();
        Map<String,Object> options =args.get('options');
        Map<String,Object> input = args.get('input');

        options.put('openai_service', '@ThisIsAServiceThatDoesNotExist');
        llmkit.call('call_openai', args);
        Map<String,Object> output = args.get('output');
        System.debug('.test_bad_service output: ' + JSON.serialize(output));

        String response = String.valueOf(args.get('output').get('error'));
        System.assert(response == 'The openai_service static resource @ThisIsAServiceThatDoesNotExist was not found');

    }

    /**
     * test_bad_model_name
     * 
     * Pass in a bad model name to see if it detects the error
     */
    @isTest
    static void test_bad_model_name() {
        LLMkit llmkit = new LLMkit();
        Map<String,Map<String,Object>> args = createArgs();
        Map<String,Object> options =args.get('options');
        Map<String,Object> input = args.get('input');

        options.put('user_template', 'I would like to buy widgets in the following colors and quantities:\n\n{% if Step1.selWhite %} White: {{ Step1.selWhite }}{% else %} {% endif %}\n{% if Step1.selBlack %} Black: {{ Step1.selBlack }} {% endif %}\n{% if Step1.selRed %} Red: {{ Step1.selRed }} {% endif %}\n{% if Step1.selBlue %} Blue: {{ Step1.selBlue }} {% endif %}\n{% if Step1.selGreen %} Green: {{ Step1.selGreen }} {% endif %}\n{% if Step1.selCyan %} Cyan: {{ Step1.selCyan }} {% endif %}\n{% if Step1.selMagenta %} Magenta: {{ Step1.selMagenta }} {% endif %}\n{% if Step1.selYellow %} Yellow: {{ Step1.selYellow }} {% endif %}\n\nIs that allowed?');
        options.put('system_template', '{# This is a comment #}\n\nYou are an order management specialist at a widget factory.  \nThere are 8 different types of widgets: \n\n* The primary colors: red, blue, and green\n* The secondary colors: yellow, magenta, and cyan\n* Two desaturated colors: black, and white.\n\nFor every cyan widget someone buys, they must also buy one more blue and one more green widget.\n\nFor every yellow widget someone buys, they must also buy an additional red and green widget.\n\nFor every magenta widget someone buys, they must also buy an additional red and a blue widget.\n\nThe widgets in red, blue, green, black, and white have no restrictions on them.\n\nThe required additional widgets are additive. Thus, if you buy two secondary colored widgets, \nyou have to buy the corresponding four primary colored widgets to meet the requirements.\n\nFor example, if you buy yellow and magenta, you will must but two reds, one green, and one blue in your order.\n\nYour job is to look at an order a customer wants to make and to verify that it follows the rules.\n\nThe way to do this is to look at each of the secondary colors, add up the required primary colors,\nand make sure the order has at least that many of each primary color.\n \nExplain your reasoning step by step.');
        options.put('model', 'google-bard');
        options.put('temperature', '0.0');
        options.put('mock_response', 'THIS IS A MOCK RESPONSE');
        options.put('named_credential', 'OpenAI');

        args.put('input', ((Map<String,Object>)JSON.deserializeUntyped('{\n\"Names\": [\n  \"Alice\", \"Bob\", \"Carl\"\n],\n  \"Step1\": {\n    \"selWhite\": \"1\",\n    \"selBlack\": \"0\",\n    \"selRed\": \"1\",\n    \"selBlue\": \"1\",\n    \"selGreen\": \"1\",\n    \"selCyan\": \"1\",\n    \"selMagenta\": \"0\",\n    \"selYellow\": \"1\"\n  }\n}')));

        llmkit.call('call_openai', args);
        String response = String.valueOf(args.get('output').get('error'));
        System.assert(response == 'I do not know of a model named google-bard');

    }


    /**
     * test_missing_nc_key
     * 
     * Test: pass in neither named_creential nor api_key
     */
    @isTest
    static void test_missing_nc_key() {
        LLMkit llmkit = new LLMkit();
        Map<String,Map<String,Object>> args = createArgs();
        Map<String,Object> options =args.get('options');
        Map<String,Object> input = args.get('input');

        options.put('user_template', 'I would like to buy widgets in the following colors and quantities:\n\n{% if Step1.selWhite %} White: {{ Step1.selWhite }}{% else %} {% endif %}\n{% if Step1.selBlack %} Black: {{ Step1.selBlack }} {% endif %}\n{% if Step1.selRed %} Red: {{ Step1.selRed }} {% endif %}\n{% if Step1.selBlue %} Blue: {{ Step1.selBlue }} {% endif %}\n{% if Step1.selGreen %} Green: {{ Step1.selGreen }} {% endif %}\n{% if Step1.selCyan %} Cyan: {{ Step1.selCyan }} {% endif %}\n{% if Step1.selMagenta %} Magenta: {{ Step1.selMagenta }} {% endif %}\n{% if Step1.selYellow %} Yellow: {{ Step1.selYellow }} {% endif %}\n\nIs that allowed?');
        options.put('system_template', '{# This is a comment #}\n\nYou are an order management specialist at a widget factory.  \nThere are 8 different types of widgets: \n\n* The primary colors: red, blue, and green\n* The secondary colors: yellow, magenta, and cyan\n* Two desaturated colors: black, and white.\n\nFor every cyan widget someone buys, they must also buy one more blue and one more green widget.\n\nFor every yellow widget someone buys, they must also buy an additional red and green widget.\n\nFor every magenta widget someone buys, they must also buy an additional red and a blue widget.\n\nThe widgets in red, blue, green, black, and white have no restrictions on them.\n\nThe required additional widgets are additive. Thus, if you buy two secondary colored widgets, \nyou have to buy the corresponding four primary colored widgets to meet the requirements.\n\nFor example, if you buy yellow and magenta, you will must but two reds, one green, and one blue in your order.\n\nYour job is to look at an order a customer wants to make and to verify that it follows the rules.\n\nThe way to do this is to look at each of the secondary colors, add up the required primary colors,\nand make sure the order has at least that many of each primary color.\n \nExplain your reasoning step by step.');
        options.put('model', 'gpt-4');
        options.put('temperature', '0.0');
        options.put('mock_response', 'THIS IS A MOCK RESPONSE');

        args.put('input', ((Map<String,Object>)JSON.deserializeUntyped('{\n\"Names\": [\n  \"Alice\", \"Bob\", \"Carl\"\n],\n  \"Step1\": {\n    \"selWhite\": \"1\",\n    \"selBlack\": \"0\",\n    \"selRed\": \"1\",\n    \"selBlue\": \"1\",\n    \"selGreen\": \"1\",\n    \"selCyan\": \"1\",\n    \"selMagenta\": \"0\",\n    \"selYellow\": \"1\"\n  }\n}')));

        llmkit.call('call_openai', args);
        String response = String.valueOf(args.get('output').get('error'));
        System.assert(response == 'Require either named_credential or api_key');

    }

    /**
     * test getSRasJSON
     */
    @isTest
    static void test_getSRasJSON(){
        LLMkit llmkit = new LLMkit();
        Map<String,Map<String,Object>> args = createArgs();
        Map<String,Object> options =args.get('options');
        options.put('resource','NORMALLY THE NAME OF A STATIC RESOURCE');
        options.put('path', 'testdata');
        options.put('mock_response','{"a":"b"}');

        llmkit.call('getSRasJSON', args);
        
        Map<String,Object> output = args.get('output');
        System.assert(output.containsKey('testdata'));
        Map<String,Object> testdata = (Map<String,Object> ) output.get('testdata');
        System.assert(testdata.containsKey('a'));
        
    }

    /**
     * test get_sr_as_json
     */
    @isTest
    static void test_get_sr_as_json(){
        LLMkit llmkit = new LLMkit();
        Map<String,Map<String,Object>> args = createArgs();
        Map<String,Object> options =args.get('options');
        options.put('resource','NORMALLY THE NAME OF A STATIC RESOURCE');
        options.put('path', 'testdata');
        options.put('mock_response','{"a":"b"}');

        llmkit.call('get_sr_as_json', args);
        
        Map<String,Object> output = args.get('output');
        System.assert(output.containsKey('testdata'));
        Map<String,Object> testdata = (Map<String,Object> ) output.get('testdata');
        System.assert(testdata.containsKey('a'));
        
    }

}