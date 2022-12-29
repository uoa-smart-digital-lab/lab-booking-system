import React, { useState } from 'react';
import 'semantic-ui-css/semantic.min.css';

import { Form, Divider, Grid, Button, Modal, Header } from 'semantic-ui-react';
import GraphQL from './graphql';
import {
    ApolloProvider,
    useMutation,
	gql
  } from "@apollo/client";



// ----------------------------------------------------------------------------------------------------
// Do the Book Item view
// ----------------------------------------------------------------------------------------------------
function View(args)
{
	// Set props and state
	const props = args.props;

	const MUTATION = GraphQL.ITEMBOOK;
	
	const [state, setState] = useState({
		starttime: props.starttime,
		endtime: props.endtime,
		upi: props.upi,
		itemname: props.itemname,
		sessionid: props.sessionid,
		set: (name, value) => { setState( previousState => { return { ...previousState, [name]: value }} ); }
	});

	// The GraphQL function being used here
	const [itemBook] = useMutation(MUTATION);

	// Do the actual login when the user presses the button
	let DoBooking = () =>
	{		
		const variables = { upi: state.upi, itemname: state.itemname, starttime: state.starttime, endtime: state.endtime, details:"{}"};
		itemBook({variables: variables})
		.then(result => props.bookedin(result.data.itemBook))
		.catch(error => {
			console.debug(error);
			props.error(error)
		})
	};

	// Hand the keypresses and changes in the UI
	let handleKeyPress = (e) => { if (e.charCode === 13) { DoBooking(); } }
	let handleChange = (e, { name, value }) => { state.set([name], value); };

	// The main UI
	return (
		<Modal open={true} size='tiny' >
			<Modal.Content>
			<Header as='h4' textAlign='center'>
				<span>Make Booking</span><br/><span>Set Start and End Times.</span><br/>
				<span>{props.errorMessage}</span>
			</Header>
			<Divider />
			<Grid columns='one'>
				<Grid.Row>
				<Grid.Column>
					<Form>
					<Form.Field>
						<Form.Input placeholder="Start Time" name="starttime" type="text" value={state.starttime} onKeyPress={handleKeyPress} onChange={handleChange}/>
					</Form.Field>
					<Form.Field>
						<Form.Input placeholder="End Time" name="endtime" type="text" value={state.endtime} onKeyPress={handleKeyPress} onChange={handleChange}/>
					</Form.Field>
					</Form>
				</Grid.Column>
				</Grid.Row>
			</Grid>
			</Modal.Content>
			<Modal.Actions style={{ paddingLeft: '1.5em', paddingRight: '1.5em' }}>
			<Grid columns='one'>
				<Grid.Row>
				<Grid.Column>
					<Button fluid basic color='green' onClick={DoBooking}>Make Booking</Button>
				</Grid.Column>
				</Grid.Row>
			</Grid>
			</Modal.Actions>
		</Modal>
	)
}
// ----------------------------------------------------------------------------------------------------



// ----------------------------------------------------------------------------------------------------
// Main Function
// ----------------------------------------------------------------------------------------------------
export default function BookItem(props) { return (<ApolloProvider client={GraphQL.client}> <View props={props} /> </ApolloProvider>); }
// ----------------------------------------------------------------------------------------------------