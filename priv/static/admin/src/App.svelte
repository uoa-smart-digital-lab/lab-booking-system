<script lang="ts">
    import Table_Persons from "./lib/Table_Persons.svelte";
    import GraphQL_Table from "./lib/GraphQL_Table.svelte";
    import { PersonDetails, GraphQL, Person} from "./lib/Graphql.svelte";
    import type { Persons, Items } from "./lib/Graphql.svelte";
    import { Usertype, Session, Item, ItemAll } from "./lib/Graphql.svelte";
    import { getClient } from 'svelte-apollo';

    // let details: PersonDetails = new PersonDetails("123456789", "here@there");

    // let persons: Persons = new Persons();
    // persons.push(new Person("rdav031", "Roy Davies", "", Usertype.ADMIN, details, 0, null, null));
    // persons.push(new Person("fdag1234", "Fred Dagg", "", Usertype.USER, details, 0, null, null));

    let connection = new GraphQL("/api");

    let session: Session = new Session();
    session.login(connection, "rdav031", "12345")
    .then(() => {
        // Login successful
        console.log("Logged in :", session);

        ItemAll(connection)
        .then((items) => {
            console.log(items);
            session.logout(connection)
            .then(() => {
                console.log("Logged out");
            })
        })
        .catch((error) => {
            console.log(error);
        });
    })
    .catch((error) => {
        console.log(error);
        // Login failed, handle error
    });



</script>

<main>
    <!-- <GraphQL_Table definition="Person" data={persons}/> -->
</main>

<style>

</style>
