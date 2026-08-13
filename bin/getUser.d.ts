import * as pulumi from "@pulumi/pulumi";
export declare function getUser(args: GetUserArgs, opts?: pulumi.InvokeOptions): Promise<GetUserResult>;
/**
 * A collection of arguments for invoking getUser.
 */
export interface GetUserArgs {
    email: string;
    organisationId: number;
}
/**
 * A collection of values returned by getUser.
 */
export interface GetUserResult {
    readonly email: string;
    readonly firstName: string;
    readonly id: number;
    readonly lastName: string;
    readonly organisationId: number;
    readonly role: string;
}
export declare function getUserOutput(args: GetUserOutputArgs, opts?: pulumi.InvokeOutputOptions): pulumi.Output<GetUserResult>;
/**
 * A collection of arguments for invoking getUser.
 */
export interface GetUserOutputArgs {
    email: pulumi.Input<string>;
    organisationId: pulumi.Input<number>;
}
//# sourceMappingURL=getUser.d.ts.map