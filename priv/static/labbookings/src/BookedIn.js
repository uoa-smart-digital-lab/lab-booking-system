import { Component } from 'react';
import 'semantic-ui-css/semantic.min.css';
import { Card, Icon, Header } from 'semantic-ui-react'


// ----------------------------------------------------------------------------------------------------
// Message after scanning in or out
// ----------------------------------------------------------------------------------------------------
class BookedIn extends Component
{
    constructor(props) {
        super (props);
        let upis=[];
        this.props.occupants.map(({upi}) => {
            upis.push(upi);
        })
        this.state = {
            bookedin : (upis.indexOf(this.props.upi.toLowerCase()) !== -1)
        }
    }

    render ()
    {
        return (
            <>
                <Header centered as="h3" color='blue' block>
                    Success
                </Header>
                <Card.Group centered>
                    <Card color={this.state.bookedin ? "green" : "blue"}>
                        <Card.Content>
                            <Icon color={this.state.bookedin ? "green" : "blue"} name='check' size='massive'/>
                        </Card.Content>
                        <Card.Content>
                            <Card.Header as="h3">You have booked {this.state.bookedin ? "IN" : "OUT"}</Card.Header>
                        </Card.Content>
                    </Card>
                </Card.Group>
            </>
        )
    }
}

export default BookedIn;
// ----------------------------------------------------------------------------------------------------
