<!------------------------------------------------------------------------------------------------------
  Login dialog box

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script lang="ts">

    import { behavior, Modal, Message, Content, Image, Actions, Button, Form, Field, Label, Input } from "svelte-fomantic-ui";
    import { mutation } from 'svelte-apollo';
    import { LOGIN } from './Graphql.svelte';
    import { convertErrorMessage } from './ErrorMessages.svelte';
	import { createEventDispatcher } from 'svelte';

    // -------------------------------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------------------------------
    export let id: string="LoginDialog";
    // -------------------------------------------------------------------------------------------------



    // -------------------------------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------------------------------
    let upi : string = "";                                      // UPI string being entered
    let password : string = "";                                 // Password string being entered
    let errorMessage : string = "";                             // Error message
    const dispatch = createEventDispatcher();                   // Event dispatcher

    // -------------------------------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------------------------------

    // The GraphQL mutation structure for login
    const doLogin = mutation(LOGIN);

    // What do do when the enter key or login button is pressed
    const handleSubmit = () => {
        console.log("LOGGING IN", upi, password);
        doLogin({ variables: { upi, password } })
        .then((result:any) => {
            errorMessage="";
            behavior(id, "hide"); 
            dispatch ('login', { message : 'success', data : result.data.login });
        })
        .catch((error : { graphQLErrors : [{ message : string }]}) => {
            errorMessage = convertErrorMessage(error.graphQLErrors[0].message);
        });
    }

    function closeLogin () {
        errorMessage="";
        behavior(id, "hide"); 
        dispatch ('login', { message : 'close', data : {}})
    }
</script>
<!----------------------------------------------------------------------------------------------------->



<!------------------------------------------------------------------------------------------------------
Styles
------------------------------------------------------------------------------------------------------->
<style>

</style>
<!----------------------------------------------------------------------------------------------------->



<!------------------------------------------------------------------------------------------------------
Layout
------------------------------------------------------------------------------------------------------->
<Modal ui tiny {id}>
    <Content>
        <Form ui>
            <Image ui src="/images/logo.png"/>
            <Field>
                <Label input>User name</Label>
                <Input text placeholder="User name" bind:value={upi}/>
            </Field>
            <Field>
                <Label input>Password</Label>
                <Input password placeholder="Password" bind:value={password}/>
            </Field>
        </Form>
        {#if errorMessage!==""}
            <Message ui error>{errorMessage}</Message>
        {/if}
    </Content>
    <Actions>
        <Button ui red on:click={()=>{closeLogin();}}>Cancel</Button>
        <Button ui green on:click={()=>{handleSubmit();}}>Log in</Button>
    </Actions>
</Modal>
<!----------------------------------------------------------------------------------------------------->
