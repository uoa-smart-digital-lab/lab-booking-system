<script lang="ts">
    // @ts-ignore
    import { behavior, Grid, Modal, Column, Row, Button, Dropdown, Input, Icon, Text, Menu, Item } from 'svelte-fomantic-ui';

    import { ApolloClient, InMemoryCache } from '@apollo/client';
    import { setClient } from 'svelte-apollo';

    import { onMount } from 'svelte';

    import type { Person } from "./lib/Graphql.svelte";

    import Login from './lib/Login.svelte';
    import MainGraphic from './lib/MainGraphic.svelte';

    let sessionid: string = "";
    let user: Person;


    onMount(() => {
        behavior("login_dialog", "show");
    })


    // -------------------------------------------------------------------------------------------------
    // GraphQL
    // -------------------------------------------------------------------------------------------------
    // GraphQL client setup 
    const client = new ApolloClient({
        uri:  '/api',
        cache: new InMemoryCache()
    });
    setClient(client);
    // -------------------------------------------------------------------------------------------------



    // -------------------------------------------------------------------------------------------------
    // Check the result of the login
    // -------------------------------------------------------------------------------------------------
    function loggedIn(event) {
        console.log(event.detail);
        switch (event.detail.message) {
            case "success":
                user = event.detail.data.person;
                sessionid = event.detail.data.sessionid;
                behavior("login_dialog", "hide");
                break;
            case "close":
                behavior("login_dialog", "hide");
                break;

            default: break;
        }
    }
    // -------------------------------------------------------------------------------------------------

</script>



<main>
    <MainGraphic/>
    <Grid ui three column>
        <Row>
            <Column> </Column>
            <Column>
                <Dropdown ui fluid>
                    <Button ui fluid basic icon blue>
                        <Icon dropdown/>
                        <Text default>Select...</Text>
                    </Button>
                    <Menu ui fluid>
                        <Item centered value="items">Items</Item>
                        <Item centered value="persons">People</Item>
                    </Menu>
                </Dropdown>
            </Column>
            <Column>
                <Button ui fluid basic icon red>
                    <Icon ui sign out alternative/>
                    logout
                </Button>
            </Column>
        </Row>
    </Grid>


    <Modal ui tiny id="login_dialog">
        <Login on:login={loggedIn}/>
    </Modal>
</main>



<style>

</style>
