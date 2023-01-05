<!------------------------------------------------------------------------------------------------------
  A login dialog box
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    // @ts-nocheck

    import { mutation } from 'svelte-apollo';
    import { Card, Divider, Input, Button, SimpleGrid, Text } from '@svelteuidev/core';
    import { LOGIN } from './Graphql.svelte';
    import type { Session } from './Graphql.svelte';
    import { convertErrorMessage } from './ErrorMessages.svelte';
	import { createEventDispatcher } from 'svelte';

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
<Card p='md'>
    {#if errorMessage}
        <Text size='md' color='red' align='center'>
            {errorMessage}
        </Text>
        <Divider variant='dotted'/>
    {/if}

    <Input placeholder='UPI' bind:value={upi} on:keydown={handleKeydown} />
    <Divider variant='dotted'/>
        
    <Input placeholder='Password' bind:value={password} on:keydown={handleKeydown} type='password' />
    <Divider variant='dotted'/>

    <SimpleGrid cols={2}>
        <Button on:click={closeLogin} variant='filled' color='blue' fullSize>
            Cancel
        </Button>
        <Button on:click={handleSubmit} variant='filled' color='green' fullSize>
            Log in
        </Button>
    </SimpleGrid>
</Card>
<!----------------------------------------------------------------------------------------------------->