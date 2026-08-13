import * as pulumi from "@pulumi/pulumi";
export declare function getOrganisation(args: GetOrganisationArgs, opts?: pulumi.InvokeOptions): Promise<GetOrganisationResult>;
/**
 * A collection of arguments for invoking getOrganisation.
 */
export interface GetOrganisationArgs {
    uuid: string;
}
/**
 * A collection of values returned by getOrganisation.
 */
export interface GetOrganisationResult {
    readonly force2fa: boolean;
    readonly id: number;
    readonly name: string;
    readonly persistTraitData: boolean;
    readonly restrictProjectCreateToAdmin: boolean;
    readonly uuid: string;
}
export declare function getOrganisationOutput(args: GetOrganisationOutputArgs, opts?: pulumi.InvokeOutputOptions): pulumi.Output<GetOrganisationResult>;
/**
 * A collection of arguments for invoking getOrganisation.
 */
export interface GetOrganisationOutputArgs {
    uuid: pulumi.Input<string>;
}
//# sourceMappingURL=getOrganisation.d.ts.map