<!------------------------------------------------------------------------------------------------------
A login dialog box
------------------------------------------------------------------------------------------------------->
<script>
    // @ts-nocheck
    import { mutation } from 'svelte-apollo';
    import { Card, Divider, Input, Button, SimpleGrid, Title } from '@svelteuidev/core';
    import { LOGIN } from './Graphql.svelte';

    export let loggedin;
    export let cancel;

    let upi = "";
    let password = "";

    function upichanged(event) { upi = event.target.value; }
    function passwordchanged(event) { password = event.target.value; }

    const Login = mutation(LOGIN);
    async function handleSubmit()
    {
        try
        {
            let result = await Login({ variables: { upi, password } });
            loggedin(result.data.login);
        }
        catch (error)
        {
            console.log(error);
        }
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
<Card>
    <Input placeholder='UPI' on:input={upichanged} />

    <Divider variant='dotted'/>

    <Input placeholder='Password' on:input={passwordchanged} type="password" />

    <Divider variant='dotted'/>

    <SimpleGrid cols={2}>
        <Button on:click={cancel} variant='filled' color='blue' fullSize>
            Cancel
        </Button>
        <Button on:click={handleSubmit} variant='filled' color='green' fullSize>
            Log in
        </Button>
    </SimpleGrid>
</Card>
<!----------------------------------------------------------------------------------------------------->