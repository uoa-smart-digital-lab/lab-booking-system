import React, { Component } from 'react';
import 'semantic-ui-css/semantic.min.css';
import { Card, Icon, Header } from 'semantic-ui-react'


// ----------------------------------------------------------------------------------------------------
// Show the current bookings for an item, ie the maximum number of spaces minus the number of occupants
// ----------------------------------------------------------------------------------------------------
class Bookings extends Component
{
    constructor(props) {
        super (props);
        this.state = 
        {
            num_spaces : this.props.max - this.props.occupants.length
        }
    }

    render ()
    {
        return (
            <>
                <Header centered as="h3" color='blue' block>
                    Bookings
                </Header>
                <Card.Group centered>
                    <Card color={this.state.num_spaces<=0 ? "red" : "blue"} icon>
                        <Card.Content>
                            <Icon color={this.state.num_spaces<=0 ? "red" : "blue"} name='university' size='massive'/>
                        </Card.Content>
                        <Card.Content>
                            <Card.Header as="h2">
                                {this.props.itemName}
                            </Card.Header>
                        </Card.Content>
                        <Card.Content>
                            <Card.Header as="h4">
                                {this.state.num_spaces} space{this.state.num_spaces === 1? "" : "s"} left.
                            </Card.Header>
                        </Card.Content>
                    </Card>
                </Card.Group>
            </>
        )
    }
}

export default Bookings;
// ----------------------------------------------------------------------------------------------------