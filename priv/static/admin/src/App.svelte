<script lang="ts">
    import Table_Persons from "./lib/Table_Persons.svelte";
    import GraphQL_Table from "./lib/GraphQL_Table.svelte";
    import { PersonDetails, GraphQL, Person, Item, Session } from "./lib/Graphql.svelte";

    // let details: PersonDetails = new PersonDetails("123456789", "here@there");

    let thePeople: Array<Person> = [];
    let theItems: Array<Item> = [];

    let connection = new GraphQL("/api");
    let loading = true;
    let error = false;

    let session: Session = new Session();
    session.login(connection, "rdav031", "12345")
    .then(() => {
        // Login successful
        console.log("Logged in :", session);

        Item.itemAll(connection, session)
        .then((items) => {
            theItems = items;
            Person.personAll(connection, session)
            .then((people) => {
                thePeople = people;
                loading = false;
            })
        })
        .catch((errorDetails) => {
            error = true;
            console.log(errorDetails);
        });
    })
    .catch((errorDetails) => {
        error = true
        console.log(errorDetails);
        // Login failed, handle error
    });



</script>

<main>
    {#if error}
        error ...
    {:else if loading}
        loading ...
    {:else}
    <GraphQL_Table definition="Person" data={thePeople}/>
    <GraphQL_Table definition="Item" data={theItems}/>
    {/if}
</main>

<style>

</style>
