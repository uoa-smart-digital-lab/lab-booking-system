<!------------------------------------------------------------------------------------------------------
  A login dialog box
------------------------------------------------------------------------------------------------------->
<script lang="ts">

    import { mutation } from 'svelte-apollo';
    import { LOGIN } from './Graphql.svelte';
    import type { Session } from './Graphql.svelte';
    import { convertErrorMessage } from './ErrorMessages.svelte';
	import { createEventDispatcher } from 'svelte';

    // @ts-ignore
    import { Card, Text, Divider, Input, Button, Grid, Column, Icon, Header, Content, Image, Description, Actions } from 'svelte-fomantic-ui';

    const dispatch = createEventDispatcher();

    // -------------------------------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------------------------------
    // export let successfulLogin : (login_data: Session) => void; // Function to call when login success
    // export let closeLoginDialog : () => void;                   // Function to call to close dialog

    // -------------------------------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------------------------------
    let upi : string = "";                                      // UPI string being entered
    let password : string = "";                                 // Password string being entered
    let errorMessage : string = "";                             // Error message

    // -------------------------------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------------------------------
    // Check for enter key and call submit when detected
    const handleKeydown = (event:any) => {
		if (event.key === 'Enter') {
            handleSubmit();
        }
    }

    // The GraphQL mutation structure for login
    const doLogin = mutation(LOGIN);

    // What do do when the enter key or login button is pressed
    const handleSubmit = () => {
        doLogin({ variables: { upi, password } })
        .then((result:any) => {
            console.log(result.data.login);

            dispatch ('login', { message : 'success', data : result.data.login });
        })
        .catch((error : { graphQLErrors : [{ message : string }]}) => {
            errorMessage = convertErrorMessage(error.graphQLErrors[0].message);
        });
    }

    function closeLogin () {
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
<Icon close/>
<Header ui h4 center aligned>
    Log in to the booking system
</Header>
<Content>
    <Description>
        <Input ui fluid>
            <Input placeholder='UPI' bind:value={upi} on:keydown={handleKeydown} />
        </Input>
        <Divider ui small/>
        <Input ui fluid>
            <Input placeholder='Password' bind:value={password} on:keydown={handleKeydown} type='password' />
        </Input>
    </Description>
    {#if errorMessage}
        <Header ui h5 medium red center aligned>{errorMessage}</Header>
    {/if}
</Content>
<Actions>
    <Grid ui two column>
        <Column>
            <Button ui fluid blue on:click={closeLogin}>
                Cancel
            </Button>
        </Column>
        <Column>
            <Button ui fluid green on:click={handleSubmit}>
                Log in
            </Button>
        </Column>
    </Grid>
</Actions>
<!----------------------------------------------------------------------------------------------------->